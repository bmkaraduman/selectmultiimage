//
//  MyEvents.swift
//  FirebaseDemo
//
//  Created by macbookpro on 6.01.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import SVProgressHUD

var StringActiveUserID : String = ""
var StringActiveEventID : String = ""
var StringActiveEventUserID : String = ""
var gzlHesap = String()
var onayGereklimi = String()
var takipcimi = String()
var onayIslemiVarmi = String()
var gl_takipciCount : Int = 0
var gl_takipEdilenCount : Int = 0
var gl_profilResmi = String()


class MyEvents: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblKullaniciAdi: UILabel!
    @IBOutlet weak var lblMotto: UILabel!
    @IBOutlet weak var lblEtkinliklerim: UILabel!
    @IBOutlet weak var lblTakipEdilen: UILabel!
    @IBOutlet weak var lblTakipciler: UILabel!
    @IBOutlet weak var tblMyEvents: UITableView!
    @IBOutlet weak var tblViewTakip: UITableView!
    @IBOutlet weak var tblViewTakipci: UITableView!
    @IBOutlet weak var imgSwitchTab: UIImageView!
    @IBOutlet weak var lblTakipEtButton: UIButton!
    @IBOutlet weak var btnTakipEt: UIButton!
    @IBOutlet weak var btnDuzenle: UIButton!
    @IBOutlet weak var btnMesaj: UIButton!
    @IBOutlet weak var imgBrand: UIImageView!
    
    var utilities = Utilities()
    
    var ActiveEventsID : String = ""
    
    var profilEtkinlikleri = [MainEtkinlik]()
    var takipcilerim = [Takipci]()
    var takipEdilenlerim = [Takipci]()
    
    @IBOutlet weak var lblSharedOk_Title: UILabel!
    
    
    @IBOutlet weak var navigationMyEvents: UINavigationBar!
    
    @IBOutlet weak var navigationItem1: UINavigationItem!
    
    
    
    @IBOutlet weak var view_SharedOK: UIView!
    
    
    var getDBSc = GetDatabaseStructure()
    override func viewDidLoad() {
        super.viewDidLoad()
        let databaseReference = Database.database().reference()
        gl_Load = true
        //Global Değişkenleri 0 layalım.
        gl_takipciCount = 0
        gl_takipEdilenCount = 0
        gl_profilResmi = ""

        
        
        //cell.viewDetay.backgroundColor = UIColor(white: 1, alpha: 0.5)
        navigationMyEvents.backgroundColor = UIColor(white: 1, alpha: 0.4)
        
        //viewSettings.isHidden = true
        //Back butonu kaldırılır.
        //self.navigationItem.setHidesBackButton(true, animated: true)
        
        let getUser = User()
        //Profil Resmi tanımlanır.
        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2
        imgProfile.layer.masksToBounds = true
        imgProfile.contentMode = .scaleAspectFill
        
        if StringActiveUserID == "" || StringActiveUserID == nil
        {
           StringActiveUserID = UserDetail.id
        }
        
        if StringActiveUserID == UserDetail.id
        {
            if UserDetail.profilImage != nil
            {
                gl_profilResmi = UserDetail.profilImage
                //Çekilen resimde hata çıkarsa eğer...
                imgProfile.sd_setImage(with: URL(string: UserDetail.profilImage )) { (image, error, cacheType, url) in
                    if error != nil
                    {
                        self.imgProfile.image = UIImage(named: "default_person")
                    }
                }
            }
            else
            {
                imgProfile.image = UIImage(named: "defaultPerson")
            }
        }
        //Mevcut kullanıcıyı değil, StringActiveUserID alınacak.
        databaseReference.child("users").child(StringActiveUserID).child("profile").child(StringActiveUserID).observe(DataEventType.value, with: { (data) in
            if data.exists()
            {
                
                let value = data.value as? NSDictionary

                getUser.GizliHesap = value?["GizliHesap"] as? String ?? ""
                getUser.AdSoyad = value?["AdSoyad"] as? String ?? ""
                getUser.KullaniciAdi = value?["KullaniciAdi"] as? String ?? ""
                self.navigationItem1.title = getUser.KullaniciAdi
                getUser.ProfilResim = value?["ProfilResim"] as? String ?? ""
                getUser.IsletmeGozukecekAd = value?["Isletme"] as? String ?? ""
                getUser.Isletmemi = value?["Isletmemi"] as? String ?? ""
                getUser.Motto = value?["Motto"] as? String ?? ""

                if let profilIsletmeDict = value?["Isletmemi"] as! String?
                {
                    self.imgBrand.isHidden = !Bool(profilIsletmeDict)!
                }
                else
                {
                    self.imgBrand.isHidden = true
                }
                
                
                gl_profilResmi = getUser.ProfilResim
                
                self.lblKullaniciAdi.text = getUser.AdSoyad
                self.lblMotto.text = getUser.Motto
            }
            
            //Takipçiler-Takip Edilenler Getirilir.
            _ = databaseReference.child("users").child(StringActiveUserID).observe(DataEventType.value, with: { (data) in
                //3.2 Takip Edilenler-Takipçiler Getirilir.
                var takipEdilenler = [String]()
                var takipEdilenlerOnaysiz = [String]()
                var takipEdenler = [String]()
                //5. Takip edilenler getirilir.
                //a. Users altında olan takip edilenler ID'leri alınır.
                if data.hasChild("Following")
                {
                    let valuesFollowing = data.value! as! NSDictionary
                    let post = valuesFollowing["Following"] as! NSDictionary
                    let postID = post.allKeys
                    for id in postID //Buradaki ID'ler UserID'lere tekabül etmektedir.
                    {
                        let followingID = post[id] as! NSDictionary
                        let onayGereklimi = followingID["onaygerekli"] as! String
                        let varIDString = id as! String
                        if onayGereklimi == "false"
                        {
                            takipEdilenler.append(varIDString)
                        }
                        else
                        {
                            takipEdilenlerOnaysiz.append(varIDString)
                        }
                    }
                    
                    gl_takipEdilenCount = takipEdilenler.count
                    self.lblTakipEdilen.text = String(gl_takipEdilenCount)
                }
                _ = databaseReference.child("users").observe(.childAdded, with: { (data) in
                    if data.hasChild("Following")
                    {
                        let valuesFollower = data.value! as! NSDictionary
                        let post = valuesFollower["Following"] as! NSDictionary
                        let postID = post.allKeys
                        for id in postID
                        {
                            let idString = id as! String
                            if StringActiveUserID == idString
                            {
                                let followerID = post[id] as! NSDictionary
                                let onayGereklimi = followerID["onaygerekli"] as! String
                                if onayGereklimi == "false"
                                {
                                    takipEdenler.append(idString)
                                }
                            }
                        }
                        
                        gl_takipciCount = takipEdenler.count
                        self.lblTakipciler.text = String(gl_takipciCount)
                        
                    }
            
            if UserDetail.id == StringActiveUserID
            {
                self.getEvents()
            }
            else
            {
                //Eğer kullanıcı kendi profili değilse profil resmi alınır.
                if getUser.ProfilResim != nil
                {
                    self.imgProfile.sd_setImage(with: URL(string: getUser.ProfilResim )) { (image, error, cacheType, url) in
                        if error != nil
                        {
                            self.imgProfile.image = UIImage(named: "default_person")
                        }
                    }
                }
                else
                {
                    self.imgProfile.image = UIImage(named: "default_person")
                }
                
                databaseReference.child("users").child(StringActiveUserID).child("profile").child(StringActiveUserID).observeSingleEvent(of: .value, with: { (data) in
                    if data.exists()
                    {
                        let value = data.value as? NSDictionary
                        gzlHesap = value?["GizliHesap"] as? String ?? ""
                    }
                    else
                    {
                        gzlHesap = "false"
                    }
                    
                    //Profiline baktığımız kullanıcıya daha önce istek gönderdik mi, onaygerekli mi
                    databaseReference.child("users").child(UserDetail.id).child("Following").child(StringActiveUserID).observeSingleEvent(of: .value, with: { (data) in
                        if data.exists()
                        {
                            let value = data.value as? NSDictionary
                            onayGereklimi = value?["onaygerekli"] as? String ?? ""
                            onayIslemiVarmi = "true"
                        }
                        else
                        {
                            onayGereklimi = "true"
                            onayIslemiVarmi = "false"
                        }
                        
                        if onayIslemiVarmi == "false"
                        {
                            self.btnTakipEt.setImage(UIImage(named: "follow"), for: .normal)
                            self.tblMyEvents.isHidden = true
                            self.view_SharedOK.isHidden = false
                            self.lblSharedOk_Title.text = "Paylaşımları Görmeye Yetkili Değilsiniz"
                        }
                        else
                        {
                            if gzlHesap == "true" && onayGereklimi == "true"
                            {
                                self.btnTakipEt.setImage(UIImage(named: "iletildiprofil"), for: .normal)
                                self.tblMyEvents.isHidden = true
                                self.view_SharedOK.isHidden = false
                                self.lblSharedOk_Title.text = "Paylaşımları Görmeye Yetkili Değilsiniz"
                                
                            }
                            else
                            {
                                self.btnTakipEt.setImage(UIImage(named: "birakbeyaz"), for: .normal)
                                self.getEvents()
                            }
                        }
                    })
                })
            }
                    
                })
                })
                })
    }
    
    
    @IBAction func btnTakipEdilen(_ sender: UIButton) {
        takipcimi = "false"
        performSegue(withIdentifier: "id_myevents_takipciler", sender: nil)
    }
    
    
    @IBAction func btnGeri(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnTakipci(_ sender: UIButton) {
        takipcimi = "true"
        performSegue(withIdentifier: "id_myevents_takipciler", sender: nil)
    }
    
    @IBAction func btnTakipEt(_ sender: UIButton) {
        let databaseReference = Database.database().reference()
        //To Do: Eğer Gizli Hesaba takip isteği yollandıysa, o kişinin mesaj kutusuna atansın.
        //Following
        //getDBSc.takipEt(userID: UserDetail.id, gizliHesap: gzlHesap, ref: databaseReference, btn: btnTakipEt, imageName: "birak")
        //Buton disable ediliR.
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        
        if onayIslemiVarmi == "true"
        {
            self.getDBSc.takipBirakProfil(userID: StringActiveUserID, ref: databaseReference, btn: self.btnTakipEt, tip: label)
            
        }
        else
        {
            if gzlHesap == "true"
            {
                self.tblMyEvents.isHidden = true
                self.getDBSc.takipEtProfil(userID: StringActiveUserID, gizliHesap: gzlHesap, ref: databaseReference, btn: self.btnTakipEt, imageName: "iletildiprofil", tip: label)
            }
            else
            {
                self.getDBSc.takipEtProfil(userID: StringActiveUserID, gizliHesap: gzlHesap, ref: databaseReference, btn: self.btnTakipEt, imageName: "birakbeyaz", tip: label)
            }
        }

    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        StringActiveUserID = ""
    }
    
    
    @IBAction func btnDuzenle(_ sender: UIButton) {
        //ps_profile_settings
        performSegue(withIdentifier: "ps_profile_settings", sender: nil)
    }
    
    @IBAction func btnMesaj(_ sender: UIButton) {
        //Chat ekranı çıkacak bu ekranda...
        performSegue(withIdentifier: "ps_myEvents_chat", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count : Int?
        if tableView == self.tblMyEvents
        {
            count = profilEtkinlikleri.count
        }
        
        return count!
    }
    
    
    func getEvents()
    {
        //Ana View Aktif Edilir diğerleri pasif edilir.
        self.tblMyEvents.isHidden = false
        self.tblMyEvents.delegate = self
        self.tblMyEvents.dataSource = self
        //SharedID'lerin olduğu String dizisi ayarlanır.
        var sharedIDs = [String]()
        //2.Kullanıcı ID ile Auth olan kullanıcı aynı ise
        if UserDetail.id == StringActiveUserID
        {
            //a. Takip Et butonu disable edilir.
            self.btnTakipEt.isHidden = true
            //b.Mesaj butonu disable edilir.
            self.btnMesaj.isHidden = true
            //c. Duzenle butonu aktif edilir.
            self.btnDuzenle.isHidden = false
        }
        else
        {
            //3. Değil ise
            //Disable olan butonlar tekrar aktif edilir.
            self.btnTakipEt.isHidden = false
            self.btnMesaj.isHidden = false
            //Enable olanlar disable edilir.
            self.btnDuzenle.isHidden = true
        }
        //4. Kullanıcının Paylaştığı Etkinlikler alınır - Yoksa da boş getirilmesi lazım.
        //Kullanıcının paylaştığı eventID'ler alınır.
        let databaseReference = Database.database().reference()
        _ = databaseReference.child("users").child(StringActiveUserID).observe(DataEventType.value, with: { (data) in
            if data.hasChild("Shared")
            {
                let valuesShared = data.value! as! NSDictionary
                let postSh = valuesShared["Shared"] as! NSDictionary
                let postID = postSh.allKeys
                for id in postID
                {
                    let sharedID = postSh[id] as! NSDictionary
                    let shEventID = sharedID["eventID"] as! String
                    sharedIDs.append(shEventID)
                }
            }
            else
            {
                self.tblMyEvents.isHidden = true
                self.view_SharedOK.isHidden = false
            }
            if sharedIDs.count > 0
            {
                _ = databaseReference.observe(DataEventType.value) { (snapshot) in
                if snapshot.hasChild("users")
                {
                    let values = snapshot.value! as! NSDictionary
                    let post = values["users"] as! NSDictionary
                    let postID = post.allKeys
                    var sehir = String()
                    var ilce = String()
                    var userProfileImage = String() 
                    var userName = String() //Yeni Kayıt Olanlara farklı isim vermek gerekebilir.
                    var profilIsletmemi = false
                    for userID in postID //Tüm kullanıcılar alınır.
                    {
                        let singleUser = post[userID] as! NSDictionary //Kullanıcı alındı. Altındaki evente ulaşılacak.
                        if let singleUserProfile = singleUser["profile"] as! NSDictionary? //Burası event sahibinin profil bilgileri olması lazım.
                        {
                            let singleProfile = singleUserProfile.value(forKey: userID as! String) as! NSDictionary
                            
                            if let userProfileImageC = singleProfile["ProfilResim"] as! String?
                            {
                                userProfileImage = userProfileImageC
                            }
                            else
                            {
                                userProfileImage = "https://i.stack.imgur.com/l60Hf.png"
                            }
                            
                            if let profilIsletmeDict = singleProfile["Isletmemi"] as! String?
                            {
                                profilIsletmemi = Bool(profilIsletmeDict)!
                            }
                            else
                            {
                                profilIsletmemi = false
                            }
                            //Kullanıcı Adı Alınır
                            userName = singleProfile["AdSoyad"] as! String
                        }
                        else
                        {
                            userProfileImage = "https://i.stack.imgur.com/l60Hf.png"
                            if UserDetail.username != nil
                            {
                                userName = "Yanlış Kullanıcı"
                            }
                        }
                        
                        if let singleEvent = singleUser["Event"] as! NSDictionary? //Event alındı. Alındaki main klasörüne ulaşılacak.
                        {
                            if  let singleMain = singleEvent["Main"] as! NSDictionary? //Main alındı. Altındaki eventID'ler alınacak.
                            {
                                let userEventsIDs = singleMain.allKeys
                                
                                for id in userEventsIDs
                                {
                                    
                                    let varmi = self.profilEtkinlikleri.contains(where: { (etkinlik) -> Bool in
                                        etkinlik.EtkinlikID == id as! String
                                    }) //Eklenen bir kullanıcının tekrar eklenmemesi için
                                    
                                    if varmi == false
                                    {
                                        if sharedIDs.contains(id as! String) {
                                            let singlePost = singleMain[id] as! NSDictionary
                                            
                                            sehir = singlePost["IL"] as! String
                                            ilce = singlePost["Ilce"] as! String
                                            
                                            let konumBilgileri =  ilce + "/" + sehir
                                            
                                            let etAdi = singlePost["Adi"] as! String
                                            let etTarihi = singlePost["Tarih"] as! String
                                            let etSaati = singlePost["Saat"] as! String
                                            let etAc = singlePost["Aciklama"] as! String
                                            let etAd = singlePost["Adres"] as! String
                                            let etResmi = singlePost["Resim1"] as! String
                                            let etResmi2 = singlePost["Resim2"] as! String
                                            let etResmi3 = singlePost["Resim3"] as! String
                                            let etResmi4 = singlePost["Resim4"] as! String
                                            let etkSuresizmi = singlePost["Suresiz"] as! String
                                            let usID = singlePost["UserID"] as! String
                                            
                                            let myEtkinlik = MainEtkinlik(etkinlik_Adi: etAdi, etkinlik_Tarihi: etTarihi, Etkinlik_Saati: etSaati, etkinlik_Aciklama: etAc, etkinlik_Suresiz: etkSuresizmi, etkinlik_Adresi: etAd, etkinlik_Ucretsiz: "False", etkinlik_Kategorisi: "Bos", etkinlik_resmi: etResmi, etkinlik_resmi2: etResmi2, etkinlik_resmi3: etResmi3, etkinlik_resmi4: etResmi4, etkinlik_konum: konumBilgileri , etkinlik_ucret: "99", etkinlik_UserID: usID, etkinlik_id: id as! String, profil_Resim: userProfileImage, user_Name: userName, begeni_Sayisi: "", ben_Varmiyim: false, comment_Count: 0, profil_Isletmemi: profilIsletmemi )
                                            
                                            self.profilEtkinlikleri.append(myEtkinlik)
                                    }
                                    }
                                }
                            }
                        }
                    }
                    
                    if self.profilEtkinlikleri.count > 0
                    {
                        self.view_SharedOK.isHidden = true
                        self.tblMyEvents.isHidden = false
                        self.tblMyEvents.reloadData()
                    }
                    else
                    {
                        self.tblMyEvents.isHidden = true
                        self.view_SharedOK.isHidden = false
                    }
                    SVProgressHUD.dismiss()
                    
                }
                else
                {
                    //Buraya ekranda birşey gösterilmeyecek...
                    self.tblMyEvents.isHidden = true
                    self.view_SharedOK.isHidden = false
                    SVProgressHUD.dismiss()
                }
            }
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tblMyEvents.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! feedCell
            if profilEtkinlikleri.count > 0
            {
                cell.lblEventname.text = profilEtkinlikleri[indexPath.row].etkinlikAdi
                cell.imgEventImage.sd_setImage(with: URL(string : profilEtkinlikleri[indexPath.row].etkinlikResimi ), completed: nil)
                cell.imgProfilImage.sd_setImage(with: URL(string: profilEtkinlikleri[indexPath.row].profilResim ), completed: nil)
                cell.lblKonum.text = profilEtkinlikleri[indexPath.row].EtkinlikKonum
                cell.lblActiveUserIDHidden.text = profilEtkinlikleri[indexPath.row].EtkinlikUserID
                cell.btnProfilName.setTitle(profilEtkinlikleri[indexPath.row].userName, for: .normal)
                cell.imgProfilImage.layer.cornerRadius = cell.imgProfilImage.frame.height / 2
                cell.imgProfilImage.layer.masksToBounds = true
                cell.imgProfilImage.contentMode = .scaleToFill
                cell.imgBrand.isHidden = !profilEtkinlikleri[indexPath.row].profilIsletmemi
                cell.viewDetay.backgroundColor = UIColor(white: 1, alpha: 0.5)
                
                if profilEtkinlikleri[indexPath.row].etkinlikSuresiz == "true"
                {
                    cell.lblTarihAy.text = "Süresiz"
                    cell.lblTarihAyText.text = "Aktivite"
                }
                else
                {
                    cell.lblTarihAy.text = utilities.ChangeDateToDay(tarih: profilEtkinlikleri[indexPath.row].etkinlikTarihi)
                    cell.lblTarihAyText.text = utilities.ChangeDateToMonth(tarih: profilEtkinlikleri[indexPath.row].etkinlikTarihi)
                }
            }
            return cell
    }
    
    var anaEtkinlik = MainEtkinlik.init(etkinlik_Adi: "", etkinlik_Tarihi: "", Etkinlik_Saati: "", etkinlik_Aciklama: "", etkinlik_Suresiz: "", etkinlik_Adresi: "", etkinlik_Ucretsiz: "", etkinlik_Kategorisi: "", etkinlik_resmi: "", etkinlik_resmi2: "", etkinlik_resmi3: "", etkinlik_resmi4: "", etkinlik_konum: "", etkinlik_ucret: "", etkinlik_UserID: "", etkinlik_id: "", profil_Resim: "", user_Name: "", begeni_Sayisi: "",ben_Varmiyim: false, comment_Count: 0, profil_Isletmemi: false)
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        anaEtkinlik.etkinlikAciklama = profilEtkinlikleri[indexPath.row].etkinlikAciklama
        anaEtkinlik.etkinlikAdi = profilEtkinlikleri[indexPath.row].etkinlikAdi
        anaEtkinlik.etkinlikResimi = profilEtkinlikleri[indexPath.row].etkinlikResimi
        anaEtkinlik.etkinlikResimi2 = profilEtkinlikleri[indexPath.row].etkinlikResimi2
        anaEtkinlik.etkinlikResimi3 = profilEtkinlikleri[indexPath.row].etkinlikResimi3
        anaEtkinlik.etkinlikResim4 = profilEtkinlikleri[indexPath.row].etkinlikResim4
        anaEtkinlik.EtkinlikKonum = profilEtkinlikleri[indexPath.row].EtkinlikKonum
        anaEtkinlik.etkinlikTarihi = utilities.ChangeDateString(tarih: profilEtkinlikleri[indexPath.row].etkinlikTarihi)
        anaEtkinlik.EtkinlikUcret = profilEtkinlikleri[indexPath.row].EtkinlikUcret
        anaEtkinlik.EtkinlikUserID = profilEtkinlikleri[indexPath.row].EtkinlikUserID
        anaEtkinlik.EtkinlikID = profilEtkinlikleri[indexPath.row].EtkinlikID
        anaEtkinlik.etkinlikSuresiz = profilEtkinlikleri[indexPath.row].etkinlikSuresiz
        anaEtkinlik.profilResim = profilEtkinlikleri[indexPath.row].profilResim
        anaEtkinlik.userName = profilEtkinlikleri[indexPath.row].userName
        anaEtkinlik.profilIsletmemi = profilEtkinlikleri[indexPath.row].profilIsletmemi
        performSegue(withIdentifier: "vw_mevents_dfeed", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vw_mevents_dfeed"
        {
            let destinationVC = segue.destination as! feedDetail
            //destinationVC.imgEtkinlikResmi =
            //destinationVC.imgEtkinlikResmi.sd_setImage(with: URL(string: anaEtkinlik.etkinlikResimi as! String), completed: nil)
            destinationVC.etkinlikDetayResimLink = anaEtkinlik.etkinlikResimi
            destinationVC.etkinlikDetayAd = anaEtkinlik.etkinlikAdi
            destinationVC.etkinlikDetayBolge = anaEtkinlik.EtkinlikKonum
            destinationVC.etkinlikDetayTarih = anaEtkinlik.etkinlikTarihi
            destinationVC.etkinlikDetayAciklama = anaEtkinlik.etkinlikAciklama
            destinationVC.etkinlikDetayFiyat = anaEtkinlik.EtkinlikUcret
            destinationVC.etkinlikID = anaEtkinlik.EtkinlikID
            destinationVC.userID = anaEtkinlik.EtkinlikUserID
            destinationVC.etkinlikSahibiImageURL = anaEtkinlik.profilResim
            destinationVC.etkinlikSuresizmi = Bool(anaEtkinlik.etkinlikSuresiz)!
            destinationVC.etkinlikSahibiUser = anaEtkinlik.userName
            destinationVC.profilIsletmemi = anaEtkinlik.profilIsletmemi
            
            destinationVC.resimler.append(anaEtkinlik.etkinlikResimi)
            if anaEtkinlik.etkinlikResimi2 != ""
            {
                destinationVC.resimler.append(anaEtkinlik.etkinlikResimi2)
            }
            if anaEtkinlik.etkinlikResimi3 != ""
            {
                destinationVC.resimler.append(anaEtkinlik.etkinlikResimi3)
            }
            if anaEtkinlik.etkinlikResim4 != ""
            {
                destinationVC.resimler.append(anaEtkinlik.etkinlikResim4)
            }
        }
    }
}


