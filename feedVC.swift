//
//  feedVC.swift
//  FirebaseDemo
//
//  Created by macbookpro on 4.08.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import SVProgressHUD
import ChameleonFramework

struct MainUser {
    
    static var id = ""
    static var username = ""
    static var email = ""
    static var userImage = ""
    
}

class feedVC: SideBarController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    //Burası Keşfet Sayfası Ve Burada Bildirimler Olmayacak.

    @IBOutlet weak var collection_etkinlikler: UICollectionView!
    
    
    @IBOutlet weak var nvBarm: UINavigationBar!
    
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var navigItem: UINavigationItem!

    
    @IBOutlet weak var view_kesfet_ok: UIView!
    
    var utilities = Utilities()
    var userMailArray = [String]()
    var postPriceArray = [String]()
    var postNameArray = [String]()
    var postDetailArray = [String]()
    var postImageArray = [String]()
    var postDateArray = [String]()
    var postLikes = [String]()
    var postLikesCount : Int = 0
    var postCommentsCount : Int = 0
    var ImLiker : Bool = false
    
    var biletUcuzFiyat = 3000.99
    var etkinlikUcretsizDurum = "false"
    
    var likeCommentList = [NotifyCommentLikes]()
    
    var eventBiletGroupList = [TicketBiletGroup]() //Kullanıcının altındaki en ucuz biletler eklenir.
    
    var Etkinliklerim = [MainEtkinlik]()
    var Etkinliklerim_temp = [MainEtkinlik]()
    
    override func viewDidLoad() {
        SVProgressHUD.show(withStatus: "Etkinlikler getiriliyor...")
        super.viewDidLoad()
        
            gl_Load = true
            MainUser.username = "Metin KARAA"
        
        
            //let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black]
//            self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [NSAttributedString.Key : Any])
        
            let height: CGFloat = 80 //whatever height you want to add to the existing height
            let bounds = self.navigationController!.navigationBar.bounds
        
            self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
        
            collection_etkinlikler.isHidden = false

            self.addSlideMenuButton()
            setupNavBar()
            collection_etkinlikler.delegate = self
            collection_etkinlikler.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
        
        let layout = self.collection_etkinlikler.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 3,left: 1,bottom: 0,right: 1)
        
            layout.itemSize = CGSize(width: ( self.collection_etkinlikler.frame.size.width - 4) / 2, height: self.collection_etkinlikler.frame.size.height/3.6)
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
            getDataFromServer()
        
    }
    
    
    
    func setupNavBar()
    {
        
        let searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: 200,height: 20))
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.placeholder = "Etkinlik Arayınız"
        searchBar.delegate = self
        //searchBar.barTintColor = UIColor.green
        searchBar.backgroundColor = UIColor.flatWhite()
        self.navigationItem.titleView = searchBar
        
    }
    
    var seen = Set<String>()
    var unique = [MainEtkinlik]()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getSearchEtkinlikler(searchBar: searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //searchtext'te yazılan şeyi alırız,
        //Açıklama'da İsimde, Şehirde geçip geçmediğine bakarız.
        
        //Etkinliklerim
        getSearchEtkinlikler(searchBar: searchBar)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        
        searchBar.endEditing(true)
    }
    
    
    func getSearchEtkinlikler(searchBar : UISearchBar)
    {
        Etkinliklerim = Etkinliklerim_temp
        unique.removeAll()
        seen.removeAll()
        if searchBar.text == ""
        {
            collection_etkinlikler.reloadData()
        }
        else
        {
            let textS = searchBar.text?.lowercased() as! String
            let EtkinliklerimAciklama = Etkinliklerim.filter({ (MainEtkinlik) -> Bool in
                return MainEtkinlik.etkinlikAciklama.lowercased().contains(textS)
            })
            
            let EtkinliklerimAd = Etkinliklerim.filter({ (MainEtkinlik) -> Bool in
                guard let text = searchBar.text?.lowercased() else {
                    return false
                }
                
                return MainEtkinlik.etkinlikAdi.lowercased().contains(text)
            })
            
            let EtkinliklerimAdres = Etkinliklerim.filter({ (MainEtkinlik) -> Bool in
                guard let text = searchBar.text?.lowercased() else {
                    return false
                }
                
                return MainEtkinlik.EtkinlikKonum.lowercased().contains(text)
            })
            
            
            if EtkinliklerimAciklama.count > 0 || EtkinliklerimAd.count > 0 || EtkinliklerimAdres.count > 0
            {
                Etkinliklerim.removeAll()
                
                Etkinliklerim.append(contentsOf: EtkinliklerimAciklama)
                Etkinliklerim.append(contentsOf: EtkinliklerimAd)
                Etkinliklerim.append(contentsOf: EtkinliklerimAdres)
                
                for getkinlik in Etkinliklerim {
                    if !seen.contains(getkinlik.EtkinlikID) {
                        unique.append(getkinlik)
                        seen.insert(getkinlik.EtkinlikID)
                    }
                }
                Etkinliklerim.removeAll()
                Etkinliklerim = unique
                
                self.collection_etkinlikler.isHidden = false
                self.view_kesfet_ok.isHidden = true
                collection_etkinlikler.reloadData()
            }
            else
            {
                    self.view_kesfet_ok.isHidden = false
                    self.collection_etkinlikler.isHidden = true
            }
        }
        
        
        
    }
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let height: CGFloat = 80 //whatever height you want to add to the existing height
//        let bounds = self.navigationController!.navigationBar.bounds
//
//        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
//    }
    
    
    
    func getDataFromServer()
    {
        let databaseReference = Database.database().reference()
       
        //Tüm eventleri göstersin
        _ = databaseReference.observe(DataEventType.value) { (snapshot) in
            
            if snapshot.hasChild("users")
            {
                let values = snapshot.value! as! NSDictionary
                let post = values["users"] as! NSDictionary
                let postID = post.allKeys
                
                
                if gl_Load == false
                {
                    self.Etkinliklerim.removeAll()
                }
                
                
                var sehir = String()
                var ilce = String()
                var userProfileImage = String()
                var userName = String() //Yeni Kayıt Olanlara farklı isim vermek gerekebilir.
                var profilIsletmemi = false
                for userID in postID //Tüm kullanıcılar alınır.
                {
                    //let eventUserID = userID as! String
                    let singleUser = post[userID] as! NSDictionary //Kullanıcı alındı. Altındaki evente ulaşılacak.
                    
                    
                    if let singleUserProfile = singleUser["profile"] as! NSDictionary?
                    {
                        let singleProfile = singleUserProfile.value(forKey: userID as! String) as! NSDictionary
                        
                        if let userProfilImageC = singleProfile["ProfilResim"] as! String?
                        {
                            userProfileImage = userProfilImageC
                        }
                        else
                        {
                            userProfileImage = "https://i.stack.imgur.com/l60Hf.png"
                        }
                        
                        if let profilIsletmeDict = singleProfile["Isletmemi"] as! String?
                        {
                            profilIsletmemi = Bool(profilIsletmeDict)!
                        }
                        
                        //Kullanıcı Adı Alınır
                        userName = singleProfile["AdSoyad"] as! String
                    }
                    else
                    {
                        userProfileImage = "https://i.stack.imgur.com/l60Hf.png"
                        
                        if UserDetail.username != nil
                        {
                            userName = UserDetail.username //OpenID harici kullanıcılar yeni üye olurken ad soyad girilmesi gerek
                        }
                    }
                    
                    if let singleEvent = singleUser["Event"] as! NSDictionary? //Event alındı. Alındaki main klasörüne ulaşılacak.
                    {
                        
//                        //Burada tüm eventler alınacak, altındaki her event için event grouplarından en ucuz olan getirilecek.
                        if let eventGroups = singleEvent["BiletGruplari"] as! NSDictionary?
                        {
                            //if let eventBiletGroup = eventGroups[self.likeCommentList[indexPath.row].id] as! NSDictionary?
                            //{
                                let biletGruplariEventlar = eventGroups.allKeys
                            
                                for eventBlGrId in biletGruplariEventlar
                                {
                                    //var eventBiletGroupList = [TicketBiletGroup]()
                                    let eventBilet = TicketBiletGroup()
                                    if let eventGrupBiletleri = eventGroups[eventBlGrId] as! NSDictionary?
                                    {
                                        let biletGruplari = eventGrupBiletleri.allKeys
                                        
                                        for biletGrId in biletGruplari
                                        {
                                            if let singleBilet = eventGrupBiletleri[biletGrId] as! NSDictionary?
                                            {
                                                let biletTutar = Double(singleBilet["Tutar"] as! String)!
                                                
                                                if self.biletUcuzFiyat > biletTutar
                                                {
                                                    self.biletUcuzFiyat = biletTutar
                                                }
                                                self.etkinlikUcretsizDurum = String(singleBilet["Ucretsiz"] as! String)
                                            }
                                        }
                                        //Bir önceki for döngüsünde işlem tamamlandıktan sonra en ucuz olan bilet alınır.
                                        eventBilet.etkinlikUcretsizDurum = self.etkinlikUcretsizDurum
                                        eventBilet.EnUcuzBilet = self.biletUcuzFiyat
                                        eventBilet.EventID = eventBlGrId as! String
                                        self.eventBiletGroupList.append(eventBilet)
                                    }
                                }
                        }
                        
                        if  let singleMain = singleEvent["Main"] as! NSDictionary? //Main alındı. Altındaki eventID'ler alınacak.
                        {
                            let userEventsIDs = singleMain.allKeys
                            
                            for id in userEventsIDs
                            {
                                let Eventid = id as! String
                                //Event->Main Altındaki Like klasörü alınır.
                                if let singlePost = singleMain[id] as! NSDictionary?
                                {
                                    let varmi = self.Etkinliklerim.contains(where: { (etkinlik) -> Bool in
                                            etkinlik.EtkinlikID == id as! String
                                        }) //Eklenen bir kullanıcının tekrar eklenmemesi için
                                        if varmi == false
                                        {
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
                                            let etkUcretsizmi = singlePost["Ucretsiz"] as! Bool
                                            let usID = singlePost["UserID"] as! String //singlePost["UserID"] as! String
                                            var enUcuz = singlePost["EnUcuz"] as! String
                                            enUcuz = enUcuz + " TL"
                                            if etkUcretsizmi == true
                                            {
                                                enUcuz = "Ücretsiz"
                                            }
                                            
//                                            let enUcuz = self.eventBiletGroupList.first(where: { (eventBiletVarMi) -> Bool in
//                                                eventBiletVarMi.EventID == Eventid
//                                            })
                                            
                                            let myEtkinlik = MainEtkinlik(etkinlik_Adi: etAdi, etkinlik_Tarihi: etTarihi, Etkinlik_Saati: etSaati, etkinlik_Aciklama: etAc, etkinlik_Suresiz: etkSuresizmi, etkinlik_Adresi: etAd, etkinlik_Ucretsiz: self.etkinlikUcretsizDurum, etkinlik_Kategorisi: "Bos", etkinlik_resmi: etResmi, etkinlik_resmi2: etResmi2, etkinlik_resmi3: etResmi3, etkinlik_resmi4: etResmi4, etkinlik_konum: konumBilgileri , etkinlik_ucret: enUcuz, etkinlik_UserID: usID, etkinlik_id: Eventid, profil_Resim: userProfileImage, user_Name : userName, begeni_Sayisi: String(self.postLikesCount), ben_Varmiyim: self.ImLiker, comment_Count: self.postCommentsCount, profil_Isletmemi: profilIsletmemi )
                                            
                                            self.Etkinliklerim.append(myEtkinlik)
                                            
                                        }
                                        
                                        self.postLikesCount = 0
                                        self.postCommentsCount = 0
                                        self.ImLiker = false
                                }
                            }
                        }
                    }
                }
                
                if self.Etkinliklerim.count > 0
                {
                    self.collection_etkinlikler.isHidden = false
                    self.collection_etkinlikler.reloadData()
                    SVProgressHUD.dismiss()
                    self.Etkinliklerim_temp = self.Etkinliklerim
                    self.view_kesfet_ok.isHidden = true
                }
                else
                {
                    self.view_kesfet_ok.isHidden = false
                    self.collection_etkinlikler.isHidden = true
                }
                
            }
            else
            {
                //Buraya ekranda birşey gösterilmeyecek...
                self.collection_etkinlikler.isHidden = true
                SVProgressHUD.dismiss()
            }
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Etkinliklerim.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                        //let cell = collection_etkinlikler.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! KesfetCell
                        let cell = collection_etkinlikler.dequeueReusableCell(withReuseIdentifier: "cellK", for: indexPath) as! KesfetCell
        
                        if Etkinliklerim.count > 0
                        {
                            //cell.lblEventDate.text = Etkinliklerim[indexPath.row].etkinlikTarihi as! String
                            cell.lblEtkinlikAdi.text = Etkinliklerim[indexPath.row].etkinlikAdi
                            
                            cell.imgEtkinlik.sd_setImage(with: URL(string : Etkinliklerim[indexPath.row].etkinlikResimi ), completed: nil)
                            
                            cell.lblEtkinlikTarih.text = utilities.ChangeDateToDay(tarih: Etkinliklerim[indexPath.row].etkinlikTarihi)
                            cell.lblEtkinlikTarih_Ay.text = utilities.ChangeDateToMonth(tarih: Etkinliklerim[indexPath.row].etkinlikTarihi)
                            cell.lblKonum.text = Etkinliklerim[indexPath.row].etkinlikAdresi
                            cell.lblEventID.text = Etkinliklerim[indexPath.row].EtkinlikID
                            cell.lblEventUserID.text = Etkinliklerim[indexPath.row].EtkinlikUserID
                            cell.layer.borderColor = UIColor.lightGray.cgColor
                            cell.layer.borderWidth = 0
//                            cell.viewDetay.backgroundColor = UIColor(white: 1, alpha: 0.5)
                            //cell.barView.backgroundColor = UIColor(white : 1, alpha: 0.5)
                            cell.barView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                            
                        }
                        return cell
    }
    
    var anaEtkinlik = MainEtkinlik.init(etkinlik_Adi: "", etkinlik_Tarihi: "", Etkinlik_Saati: "", etkinlik_Aciklama: "", etkinlik_Suresiz: "", etkinlik_Adresi: "", etkinlik_Ucretsiz: "", etkinlik_Kategorisi: "", etkinlik_resmi: "", etkinlik_resmi2: "", etkinlik_resmi3: "", etkinlik_resmi4: "", etkinlik_konum: "", etkinlik_ucret: "", etkinlik_UserID: "", etkinlik_id: "", profil_Resim: "", user_Name: "", begeni_Sayisi: "", ben_Varmiyim: false, comment_Count: 0, profil_Isletmemi: false)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vw_mfeed_dfeed"
        {
            let destinationVC = segue.destination as! feedDetail
            //destinationVC.imgEtkinlikResmi =
            //destinationVC.imgEtkinlikResmi.sd_setImage(with: URL(string: anaEtkinlik.etkinlikResimi as! String), completed: nil)
            destinationVC.etkinlikDetayResimLink = anaEtkinlik.etkinlikResimi
            destinationVC.etkinlikDetayAd = anaEtkinlik.etkinlikAdi
            destinationVC.etkinlikDetayBolge = anaEtkinlik.EtkinlikKonum
            destinationVC.etkinlikDetayTarih = anaEtkinlik.etkinlikTarihi
            destinationVC.etkinlikSuresizmi = Bool(anaEtkinlik.etkinlikSuresiz)!
            destinationVC.etkinlikDetayAciklama = anaEtkinlik.etkinlikAciklama
            destinationVC.etkinlikDetayFiyat = anaEtkinlik.EtkinlikUcret
            destinationVC.etkinlikID = anaEtkinlik.EtkinlikID
            destinationVC.userID = anaEtkinlik.EtkinlikUserID
            destinationVC.etkinlikSahibiImageURL = anaEtkinlik.profilResim
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
    
    var EmptyNotifyCommentLikes = NotifyCommentLikes()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                    anaEtkinlik.etkinlikAciklama = Etkinliklerim[indexPath.row].etkinlikAciklama
                    anaEtkinlik.etkinlikAdi = Etkinliklerim[indexPath.row].etkinlikAdi
                    anaEtkinlik.etkinlikResimi = Etkinliklerim[indexPath.row].etkinlikResimi
                    anaEtkinlik.etkinlikResimi2 = Etkinliklerim[indexPath.row].etkinlikResimi2
                    anaEtkinlik.etkinlikResimi3 = Etkinliklerim[indexPath.row].etkinlikResimi3
                    anaEtkinlik.etkinlikResim4 = Etkinliklerim[indexPath.row].etkinlikResim4
                    anaEtkinlik.EtkinlikKonum = Etkinliklerim[indexPath.row].EtkinlikKonum
                    anaEtkinlik.etkinlikTarihi = Etkinliklerim[indexPath.row].etkinlikTarihi
                    anaEtkinlik.EtkinlikUcret = Etkinliklerim[indexPath.row].EtkinlikUcret
                    anaEtkinlik.etkinlikUcretsiz = Etkinliklerim[indexPath.row].etkinlikUcretsiz
                    anaEtkinlik.EtkinlikUserID = Etkinliklerim[indexPath.row].EtkinlikUserID
                    anaEtkinlik.EtkinlikID = Etkinliklerim[indexPath.row].EtkinlikID
                    anaEtkinlik.etkinlikSuresiz = Etkinliklerim[indexPath.row].etkinlikSuresiz
                    anaEtkinlik.profilResim = Etkinliklerim[indexPath.row].profilResim
                    anaEtkinlik.userName = Etkinliklerim[indexPath.row].userName
                    anaEtkinlik.profilIsletmemi = Etkinliklerim[indexPath.row].profilIsletmemi
                    performSegue(withIdentifier: "vw_mfeed_dfeed", sender: nil)
    }
}

extension Array where Element: Hashable {
    func distinct() -> Array<Element> {
        var set = Set<Element>()
        return filter {
            guard !set.contains($0) else { return false }
            set.insert($0)
            return true
        }
    }
}
