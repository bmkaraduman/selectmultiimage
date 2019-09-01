//
//  takipciler.swift
//  FirebaseDemo
//
//  Created by macbookpro on 3.02.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage


var gl_Load : Bool = true


class takipciler: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var imgTakipEdilenLine: UIImageView!
    
    @IBOutlet weak var imgTakipcilerLine: UIImageView!
    
    @IBOutlet weak var lblTakipEdilenSayi: UILabel!
    
    @IBOutlet weak var lblTakipcilerSayi: UILabel!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var tblViewTakip: UITableView!
    
    @IBOutlet weak var tblViewTakipci: UITableView!
    
    @IBOutlet weak var vw_ana: UIView!
    
    @IBOutlet weak var viewTakipciler_ok: UIView!
    @IBOutlet weak var viewTakipciler_OkMessage: UILabel!
    
    
    var indexRowTagTakipci : Int = 0
    
    //var getDBSc = GetDatabaseStructure()
    
    
    var takipcilerim = [Takipci]()
    var takipEdilenlerim = [Takipci]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gl_Load = true

        if takipcimi == "true"
        {
            imgTakipEdilenLine.isHidden = true
            imgTakipcilerLine.isHidden = false
            
            tblViewTakip.isHidden = true
            tblViewTakipci.isHidden = false
        }
        else
        {
            imgTakipEdilenLine.isHidden = false
            imgTakipcilerLine.isHidden = true
            
            tblViewTakip.isHidden = false
            tblViewTakipci.isHidden = true
        }
        
        lblTakipcilerSayi.text = String(gl_takipciCount)
        lblTakipEdilenSayi.text = String(gl_takipEdilenCount)
        
        if gl_profilResmi != ""
        {
            imgProfile.sd_setImage(with: URL(string: gl_profilResmi )) { (image, error, cacheType, url) in
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
        
        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2
        imgProfile.layer.masksToBounds = true
        imgProfile.contentMode = .scaleAspectFill
        
                    if gzlHesap == "true" && onayGereklimi == "true" && UserDetail.id != StringActiveUserID
                    {
                        vw_ana.isHidden = false
                        tblViewTakip.isHidden = true
                        tblViewTakipci.isHidden = true
                    }
                    else
                    {

                        self.tblViewTakip.delegate = self
                        self.tblViewTakip.dataSource = self
        
                        self.tblViewTakipci.delegate = self
                        self.tblViewTakipci.dataSource = self
              
                        //4. Kullanıcının Paylaştığı Etkinlikler alınır - Yoksa da boş getirilmesi lazım.
                        //Kullanıcının paylaştığı eventID'ler alınır.
                        let databaseReference = Database.database().reference()
                        //(sharedIDs, hata) = getDBSc.shareList(pageUserID: StringActiveUserID)
                        _ = databaseReference.child("users").child(StringActiveUserID).observe(DataEventType.value, with: { (data) in
                            
                            //3.2 Takip Edilenler-Takipçiler Getirilir.
                            
                            var takipEdilenListe = [TakipListe]()
                            var takipciListe = [TakipListe]()
                            
                            
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
                                    let onayGereklimiActiveUserFollowings = followingID["onaygerekli"] as! String
                                    let takipEdilenL = TakipListe()
                                    if onayGereklimiActiveUserFollowings == "false" //Kullanıcılara bakılır. Eğer varsa ve
                                    {
                                        //Alınan kullanıcıların takip edilip edilmemesi gerektiği giriş yapılan kullanıcıya ait olduğundan kullanıcılar tek tek kontrol edilir.
                                        _ = databaseReference.child("users").child(UserDetail.id).child("Following").child(id as! String).observeSingleEvent(of: .value, with: { (data) in
                                            if data.exists() //Burayı da içeri almak gerekecek
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
                                            
                                            let varIDString = id as! String
                                            
                                            takipEdilenL.ID = varIDString
                                            if onayGereklimi == "false" //Bu zaten kayır olduğu anlamına gelir. Buton bırak olacak zaten
                                            {
                                                takipEdilenL.Durum = "0"
                                            }
                                            else
                                            {
                                                if onayIslemiVarmi == "true" //Eğer onay işlemi varsa ve onay gerekli ise buton "iletildi" olacak.
                                                {
                                                    takipEdilenL.Durum = "3"
                                                    
                                                } //Eğer onay işlemi yoksa hiç kayıt olmadığı anlamına gelir. Buton Takip Et olacak. Aşağıda hesabın gizli olup olmadığına bakılır.
                                                else
                                                {
                                                    takipEdilenL.Durum = "1"
                                                }
                                            }
                                            takipEdilenListe.append(takipEdilenL)
                                        })
                                    }
                                }
                            }
                            
                            
                            //3.3 (takipEdenler, hata) = getDBSc.followerList(userID: StringActiveUserID) - Takip edenler getirilir.
                            //Beni takip edenler getirilir. Burada tüm kullanıcılara bakılır. //Takipçilerim getirilir.
                            _ = databaseReference.observe(.value, with: { (data) in
                                
                                if data.hasChild("users")
                                {
                                    let valuesUsers = data.value! as! NSDictionary
                                    let users = valuesUsers["users"] as! NSDictionary
                                    let userIDs = users.allKeys
                                    //Tüm kullanıcılara bakılır.
                                    for userID in userIDs
                                    {
                                        let singleUser = users[userID] as! NSDictionary
                                        //Tüm kullanıcılar altında followinge bakılır
                                        if let singleFollowing = singleUser["Following"] as! NSDictionary?
                                        {
                                            let userFollowingIds = singleFollowing.allKeys
                                            //Following altında userlara bakılır
                                            for id in userFollowingIds
                                            {
                                                let takipciL = TakipListe()
                                                
                                                let idString = id as! String
                                                //Eğer bu user ekrandaki user ise
                                                if StringActiveUserID == idString
                                                {
                                                    let followerID = singleFollowing[id] as! NSDictionary
                                                    let onayGereklimiFollowerIds = followerID["onaygerekli"] as! String
                                                    
                                                    if onayGereklimiFollowerIds == "false"
                                                    {
                                                        //Burası yanlış oldu, eğer following altında bulduysak adamı, kim takip etmişse onu getirmemiz gerekecek. Aşağıdaki UserDetail.ID olmasının sebebi giriş yapan kullanıcının, başka birisinin profiline baksa bile mevcut kullanıcının takipçileri ile ilgili durumu takip ediyor mu etmiyor mu?
                                                        let varIDString = userID as! String
                                                        
                                                        _ = databaseReference.child("users").child(UserDetail.id).child("Following").child(varIDString).observeSingleEvent(of: .value, with: { (data) in
                                                            if data.exists()
                                                            {
                                                                let value = data.value as? NSDictionary
                                                                
                                                                onayGereklimi = value?["onaygerekli"] as? String ?? ""
                                                                if onayGereklimi == "true"
                                                                {
                                                                    takipciL.Durum = "3"
                                                                }
                                                                else
                                                                {
                                                                    takipciL.Durum = "0"
                                                                }
                                                                onayIslemiVarmi = "true"
                                                            }
                                                            else
                                                            {
                                                                onayGereklimi = "true"
                                                                onayIslemiVarmi = "false"
                                                                
                                                                takipciL.Durum = "1"
                                                            }
                                                            
                                                            takipciL.ID = varIDString
                                                            
                                                            takipciListe.append(takipciL)
                                                        })
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
        
                                
                                _ = databaseReference.child("users").observe(DataEventType.childAdded) { (snapShot) in
                                        //Eğer etkinliği paylaşan satıcı ise, etkinliği paylaştığı anda, shared kısmına da eventID'yi at...
                                        let values = snapShot.value! as! NSDictionary
                                    
                                        if takipEdilenListe.count > 0 || takipciListe.count > 0
                                        { //Takip edilenlerin bilgileri alınacak.
                                            if snapShot.hasChild("profile")  //Todo: Profil olması tüm kullanıcılar olduğu anlamına gelmez. En başta profili doldurmak gerekecek.
                                            {//Profile dosyasına da kullanıcı ID'si eklenecek.
                                                let post = values["profile"] as! NSDictionary
                                                let postIds = post.allKeys
                                                //Profilin altındaki tüm userID'ler alındı.
                                                for id in postIds
                                                {
                                                    let idString = id as! String
                                                    //İlgili User'ın takip edilenleri alınır. Sonra yukarıdan gelen ID ile eşleştirilerek USER bilgileri alınır.
                                                    if takipEdilenListe.count > 0
                                                    {
                                                        
                                                        var profilIDBul = takipEdilenListe.contains(where: { (profilID) -> Bool in
                                                            profilID.ID == idString
                                                        })
                                                        //Eğer kullanıcı kendi profiline bakıyorsa kıyaslanmasına hepsinin gelmesi lazım zaten.
                                                        if StringActiveUserID == UserDetail.id
                                                        {
                                                            profilIDBul = true
                                                        }
                                                        
                                                        if profilIDBul == true
                                                        {
                                                            let varmi = self.takipEdilenlerim.contains(where: { (takipciNaber) -> Bool in
                                                                takipciNaber.User_ID == idString
                                                            }) //Eklenen bir kullanıcının tekrar eklenmemesi için
                                                            
                                                            if varmi == false
                                                            {
                                                                let singlePost = post[id] as! NSDictionary
                                                                
                                                                if takipEdilenListe.count > 0
                                                                {
                                                                    
                                                                    let indexTakipEdilen = takipEdilenListe.firstIndex(where: { (TakipListe) -> Bool in
                                                                        TakipListe.ID == idString
                                                                    })
                                                                    
                                                                    if indexTakipEdilen != nil
                                                                    {
                                                                        var kk = singlePost["AdSoyad"] as? String
                                                                        if kk == ""
                                                                        {
                                                                          kk = singlePost["KullaniciAdi"] as? String
                                                                        }
                                                                        
                                                                        let takipcim = Takipci(adi: kk!, resim: singlePost["ProfilResim"] as? String ?? "https://image.istanbul.net.tr/uploads/2018/12/event/merhaba-770x470.jpg", durum: takipEdilenListe[indexTakipEdilen!].Durum, userID: idString, gizlimi: singlePost["GizliHesap"] as! String)
                                                                        self.takipEdilenlerim.append(takipcim)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    if takipciListe.count > 0
                                                    {
                                                        var profilIDBul = takipciListe.contains(where: { (profilID) -> Bool in
                                                            profilID.ID == idString
                                                        })
                                                        
                                                        if StringActiveUserID == UserDetail.id //Eğer kullanıcı kendi profiline bakıyorsa kıyaslanmasına hepsinin gelmesi lazım zaten.
                                                        {
                                                            profilIDBul = true
                                                        }
                                                        
                                                        if profilIDBul == true //Takipçilerim içerisindeki ID'ler alınır.
                                                        {
                                                            let varmi = self.takipcilerim.contains(where: { (takipciNaber) -> Bool in
                                                                takipciNaber.User_ID == idString
                                                            }) //Daha önce bu ID takipçilerime eklendi mi eklenmedi mi kontrol edilir.
                                                            
                                                            if varmi == false
                                                            {
                                                                let singlePost = post[id] as! NSDictionary
                                                                
                                                                if takipciListe.count > 0
                                                                {
                                                                    
                                                                    let indexTakipEdilen = takipciListe.firstIndex(where: { (TakipListe) -> Bool in
                                                                        TakipListe.ID == idString
                                                                    })
                                                                    
                                                                    if indexTakipEdilen != nil
                                                                    {
                                                                        
                                                                        var ll = singlePost["AdSoyad"] as? String
                                                                        if ll == ""
                                                                        {
                                                                            ll = singlePost["KullaniciAdi"] as? String
                                                                        }
                                                                        
                                                                        let takipcim = Takipci(adi: ll!, resim: singlePost["ProfilResim"] as? String ?? "https://image.istanbul.net.tr/uploads/2018/12/event/merhaba-770x470.jpg", durum: takipciListe[indexTakipEdilen!].Durum, userID: idString, gizlimi: singlePost["GizliHesap"] as! String)
                                                                        self.takipcilerim.append(takipcim)
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    //Burada 2 tableview 1 tane de eğer katılımcı yoksa kişilerin gösterildiği viewTakipciler_ok tablosu var. Eğer aşağıdaki if-elseler MyEvents'ten hangi butona tıklandıysa ona göre getirilecek olan ayarlamalardır.
                                    if gl_Load == true
                                    {
                                        self.tblViewTakip.reloadData()
                                        self.tblViewTakipci.reloadData()
                                        
                                        if takipcimi == "true"
                                        {
                                            if self.takipcilerim.count > 0
                                            {
                                                self.viewTakipciler_ok.isHidden = true
                                                self.tblViewTakipci.isHidden = false
                                                self.tblViewTakip.isHidden = true
                                                
                                                self.imgTakipEdilenLine.isHidden = true
                                                self.imgTakipcilerLine.isHidden = false
                                            }
                                            else
                                            {
                                                self.tblViewTakipci.isHidden = true
                                                self.tblViewTakip.isHidden = true
                                                self.viewTakipciler_ok.isHidden = false
                                                self.viewTakipciler_OkMessage.text = "Şimdilik Takipçiniz Bulunmuyor"
                                            }
                                        }
                                        else
                                        {
                                            if self.takipEdilenlerim.count > 0
                                            {
                                                self.viewTakipciler_ok.isHidden = true
                                                
                                                self.tblViewTakipci.isHidden = true
                                                self.tblViewTakip.isHidden = false
                                                
                                                self.imgTakipEdilenLine.isHidden = false
                                                self.imgTakipcilerLine.isHidden = true
                                            }
                                            else
                                            {
                                                self.tblViewTakip.isHidden = true
                                                self.tblViewTakip.isHidden = true
                                                self.viewTakipciler_ok.isHidden = false
                                                self.viewTakipciler_OkMessage.text = "Şimdilik Takip Ettiğiniz Kimse Bulunmuyor"
                                            }
                                        }
                                        
                                        if self.takipEdilenlerim.count == 0 && self.takipcilerim.count == 0
                                        {
                                            self.tblViewTakip.isHidden = true
                                            self.tblViewTakipci.isHidden = true
                                            self.viewTakipciler_ok.isHidden = false
                                        }
                                    }
                                    
                                    
                                    
                                    }
                                    //3.5 Sonu
        
                                //3.4 Sonu
                            }) { (error) in
                                print(error.localizedDescription)
                            }
                            //3.3 Sonu
                        })
                    }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblViewTakip
        {
            return takipEdilenlerim.count
        }
        else
        {
            return takipcilerim.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Eğer hesap gizli ise görüntülenmeyecek.
        
            if tableView == self.tblViewTakip
            {
                let cellTakipEdilen = tblViewTakip.dequeueReusableCell(withIdentifier: "cellTakip", for: indexPath) as! ProfilCell
                
                
                cellTakipEdilen.imgView.layer.cornerRadius = cellTakipEdilen.imgView.frame.height / 2
                cellTakipEdilen.imgView.layer.masksToBounds = true
                cellTakipEdilen.imgView.contentMode = .scaleAspectFill
                
                
                // add border and color
                //cellTakipEdilen.backgroundColor = UIColor.flatSkyBlue()
                
                if indexPath.row % 2 == 0
                {
                    
                    if indexPath.row == 0 && takipEdilenlerim.count == 1
                    {
                        let border = CALayer()
                        let width = CGFloat(1.0)
                        border.borderColor = UIColor.flatGray()?.cgColor
                        border.frame = CGRect(x: 0, y: cellTakipEdilen.frame.size.height - width, width:  cellTakipEdilen.frame.size.width, height: cellTakipEdilen.frame.size.height)
                        
                        border.borderWidth = width
                        cellTakipEdilen.layer.addSublayer(border)
                    }
                    else
                    {
                        cellTakipEdilen.layer.borderWidth = 0
                    }
                    
                    
                    if indexPath.row == takipEdilenlerim.count - 1 && takipEdilenlerim.count != 1
                    {
                        cellTakipEdilen.layer.borderColor = UIColor.flatGray()?.cgColor
                        cellTakipEdilen.layer.borderWidth = 1
                    }
                    
                }
                else
                {
                    cellTakipEdilen.layer.borderColor = UIColor.flatGray()?.cgColor
                    cellTakipEdilen.layer.borderWidth = 1
                }
                //cellTakipEdilen.layer.cornerRadius = 10
                cellTakipEdilen.clipsToBounds = true
                
                
                
                
                cellTakipEdilen.imgView.sd_setImage(with: URL(string: takipEdilenlerim[indexPath.row].Resim), completed: nil)
                cellTakipEdilen.lblUserName.text = takipEdilenlerim[indexPath.row].Adi
                //cellTakipEdilen.lblTakipEdilenHiddenTasiyici.text = takipEdilenlerim[indexPath.row].User_ID
                cellTakipEdilen.user_id = takipEdilenlerim[indexPath.row].User_ID
                //                cellTakipEdilen.lblTakipDurumHidden.text = takipEdilenlerim[indexPath.row].Durum as! String
                //                cellTakipEdilen.lblTakipEdilenHiddenTasiyici.text = takipEdilenlerim[indexPath.row].Gizlimi as! String
                cellTakipEdilen.whichTableView = "takip"
                cellTakipEdilen.index = indexPath
                let durum = takipEdilenlerim[indexPath.row].Durum
                
                cellTakipEdilen.gizlimi = takipEdilenlerim[indexPath.row].Gizlimi
                if gl_Load == true
                {
                    cellTakipEdilen.lblTakipDurumHidden.text = durum
                    if durum == "0" // Zaten takip Ediliyor- O yüzden buton bırak olacak.
                    {
                        cellTakipEdilen.btnTakiple.setImage(UIImage(named: "birak"), for: .normal)
                    }
                    else if durum == "1"  //Herhangi bir işlem yoksa - Takip Et butonu olacak
                    {
                        cellTakipEdilen.btnTakiple.setImage(UIImage(named: "takipetmavi"), for: .normal)
                    }
                    else if durum == "3" //Kayıt İşlemi var ancak HEsap gizli ise iletildi olacak
                    {
                        //Zaten takip ediyorsan, "İstek Gönderildi" işaretlemen lazım.
                        cellTakipEdilen.btnTakiple.setImage(UIImage(named: "iletildi"), for: .normal)
                    }
                }
                return cellTakipEdilen
            }
            else
            {
                
                let cellTakipciler = tblViewTakipci.dequeueReusableCell(withIdentifier: "cellTakipci", for: indexPath) as! ProfilCell
                
                cellTakipciler.imgView.layer.cornerRadius = cellTakipciler.imgView.frame.height / 2
                cellTakipciler.imgView.layer.masksToBounds = true
                cellTakipciler.imgView.contentMode = .scaleAspectFill
                
                
                // add border and color
                //cellTakipciler.backgroundColor = UIColor.flatGreen()
                //cellTakipciler.layer.borderColor = UIColor.flatGray()?.cgColor
                if indexPath.row % 2 == 0
                {
//                    cellTakipciler.layer.borderWidth = 0
//
//                    if indexPath.row == takipcilerim.count - 1
//                    {
//                        cellTakipciler.layer.borderWidth = 0
//                    }
                    if indexPath.row == 0 && takipcilerim.count == 1
                    {
                        let border = CALayer()
                        let width = CGFloat(1.0)
                        border.borderColor = UIColor.flatGray()?.cgColor
                        border.frame = CGRect(x: 0, y: cellTakipciler.frame.size.height - width, width:  cellTakipciler.frame.size.width, height: cellTakipciler.frame.size.height)
                        
                        border.borderWidth = width
                        cellTakipciler.layer.addSublayer(border)
                    }
                    else
                    {
                        cellTakipciler.layer.borderWidth = 0
                    }
                    
                    
                    if indexPath.row == takipcilerim.count - 1 && takipcilerim.count != 1
                    {
                        cellTakipciler.layer.borderColor = UIColor.flatGray()?.cgColor
                        cellTakipciler.layer.borderWidth = 1
                    }
                }
                else
                {
                    cellTakipciler.layer.borderColor = UIColor.flatGray()?.cgColor
                    cellTakipciler.layer.borderWidth = 1
                }
                
                
                
                
                
                
                
                
                
                
                
                //cellTakipciler.layer.cornerRadius = 10
                //cellTakipciler.clipsToBounds = true
                
                
                //Adamın image profil resmi yoksa default koymak lazım
                cellTakipciler.imgView.sd_setImage(with: URL(string: takipcilerim[indexPath.row].Resim), completed: nil)
                cellTakipciler.whichTableView = "takipci"
                cellTakipciler.lblUserName.text = takipcilerim[indexPath.row].Adi
                //cellTakipciler.lblTakipciHiddenTasiyici.text = takipcilerim[indexPath.row].User_ID as! String
                cellTakipciler.user_id = takipcilerim[indexPath.row].User_ID
                let durum = takipcilerim[indexPath.row].Durum
                //                cellTakipciler.lblTakipciDurumHidden.text = durum
                //                cellTakipciler.lblTakipciHiddenTasiyici.text = takipcilerim[indexPath.row].Gizlimi as! String
                
                
                cellTakipciler.gizlimi = takipcilerim[indexPath.row].Gizlimi
                
                indexRowTagTakipci = takipcilerim.count
                //Button için
                cellTakipciler.index = indexPath
                if gl_Load == true
                {
                    cellTakipciler.lblTakipciDurumHidden.text = durum
                    if durum == "0" // Zaten takip Ediliyor- O yüzden buton bırak olacak.
                    {
                        cellTakipciler.btnTakiple.setImage(UIImage(named: "birak"), for: .normal)
                    }
                    else if durum == "1"  //Herhangi bir işlem yoksa - Takip Et butonu olacak
                    {
                        cellTakipciler.btnTakiple.setImage(UIImage(named: "takipetmavi"), for: .normal)
                    }
                    else if durum == "3" //Kayıt İşlemi var ancak HEsap gizli ise iletildi olacak
                    {
                        //Zaten takip ediyorsan, "İstek Gönderildi" işaretlemen lazım.
                        cellTakipciler.btnTakiple.setImage(UIImage(named: "iletildi"), for: .normal)
                    }
                }
                return cellTakipciler
            }
        
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    @IBAction func btnTakipEdilen(_ sender: UIButton) {
        imgTakipEdilenLine.isHidden = false
        imgTakipcilerLine.isHidden = true

        if self.takipEdilenlerim.count > 0
        {
            tblViewTakip.isHidden = false
            tblViewTakipci.isHidden = true
            viewTakipciler_ok.isHidden = true
        }
        else
        {
            tblViewTakip.isHidden = true
            tblViewTakipci.isHidden = true
            viewTakipciler_ok.isHidden = false
            viewTakipciler_OkMessage.text = "Şimdilik Takip Ettiğiniz Kimse Bulunmuyor"
        }
    }
    
    @IBAction func btnTakipciler(_ sender: UIButton) {
        imgTakipcilerLine.isHidden = false
        imgTakipEdilenLine.isHidden = true
        
        if self.takipcilerim.count > 0
        {
            tblViewTakip.isHidden = true
            tblViewTakipci.isHidden = false
            viewTakipciler_ok.isHidden = true
        }
        else
        {
            tblViewTakip.isHidden = true
            tblViewTakipci.isHidden = true
            viewTakipciler_ok.isHidden = false
            viewTakipciler_OkMessage.text = "Şimdilik Takipçiniz Bulunmuyor"
        }
        
    }
    
    @IBAction func btnGeri(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
