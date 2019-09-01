//
//  SharedFeed.swift
//  FirebaseDemo
//
//  Created by macbookpro on 9.03.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//
//Burası Anasayfa
import UIKit
import Firebase
import SDWebImage
import SVProgressHUD


var webSiteName = ""
var selectedEventImage = ""
var selectedEventName = ""
var selectedEventID = ""
var selectedEventUserId = ""

class SharedFeed: SideBarController, UITableViewDelegate, UITableViewDataSource,MyCustomCellDelegator  {    
    
    @IBOutlet weak var btnFeedMain: UIButton!
    
    @IBOutlet weak var btnNotifications: UIButton!
    
    @IBOutlet weak var btnFriends: UIButton!
    
    @IBOutlet weak var tblNotifications: UITableView!

    @IBOutlet weak var tblViewEvents: UITableView!
    
    @IBOutlet weak var tblViewFriendBildirimler: UITableView!
    
    @IBOutlet weak var nvBarm: UINavigationBar!
    
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    var getDBSc = GetDatabaseStructure()
    var eventBiletGroupList = [TicketBiletGroup]()
    
    @IBOutlet weak var viewShared_Ok: UIView!
    @IBOutlet weak var viewShared_OkMessage: UILabel!
    
    @IBOutlet weak var navigItem: UINavigationItem!
    var biletUcuzFiyat = 3000.99
    var etkinlikUcretsizDurum = "false"
    var utilities = Utilities()
    var userMailArray = [String]()
    var postPriceArray = [String]()
    var postNameArray = [String]()
    var postDetailArray = [String]()
    var postImageArray = [String]()
    var postDateArray = [String]()
    var postLikes = [String]()
    
    var takipEdilenListe = [String]()
    var postLikesCount : Int = 0
    var postCommentsCount : Int = 0
    var ImLiker : Bool = false
    var sharedIDs = [String]()
    
    var Etkinliklerim = [MainEtkinlik]()
    var likeCommentList = [NotifyCommentLikes]()
    var bildirimFriendList = [NotifyFriends]()
    var sharedLoad = false
    var takipIsteklerim = [TakipListe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gl_Load = true
        MainUser.username = "Metin KARAA"
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as! [NSAttributedString.Key : Any]
        //Anasayfadan kaldırıldı.
        //self.addSlideMenuButton()
        SVProgressHUD.show(withStatus: "Etkinlikler getiriliyor...")
        tblViewEvents.delegate = self
        tblViewEvents.dataSource = self
        
        tblNotifications.delegate = self
        tblNotifications.dataSource = self
        tblNotifications.isHidden = true
        
        tblViewFriendBildirimler.delegate = self
        tblViewFriendBildirimler.dataSource = self
        tblViewFriendBildirimler.isHidden = true
        
        
                Database.database().reference().child("Website").observe(DataEventType.value, with:
                    {
                        (snapshot) in
                        //let values = snapshot.value! as! NSDictionary
                        let values = snapshot.value! as! [String: Any]
                        webSiteName = values["Name"] as! String
                }
                )
        
        //Website
        
        if sharedLoad == false
        {
            sharedLoad = true
            getDataFromServer()
        }
    }
//    var freshLaunch = true
//    override func viewWillAppear(_ animated: Bool) {
//        //Açılır açılmaz keşfet kısmına düşmesi için...
//        if freshLaunch == true {
//            freshLaunch = false
//            self.tabBarController!.selectedIndex = 2 // 5th tab
//        }
//    }
    
    func getDataFromServer()
    {
        //Current User alınmayacak, bu ekranda takip ettikleri gözükecek.
        
        let databaseReference = Database.database().reference()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        _ = storageRef.child("ActivityImages")
        
        //1.Öncelikle takip edilen liste arasında kendimiz de varız. O yüzden giriş yaptığımız kullanıcımızı da ekledik.
        //2.Ardından takip ettiklerimiz alındı. 3. Bunlar arasında shared olanlar eventları alınıp kaydedilecek.
        takipEdilenListe.append(UserDetail.id)
        //Kullanıcıya ait tüm takip edilenler alınır.
        
        _ = databaseReference.observe(.value) { (dataS) in
            //Burada birden fazla durum söz konusu
            //1. Eğer hesabınız gizli değilse sizi direk takip edebilir o yüzden sizi takip etti mesajı gelmesi lazım.
            //2. Eğer hesabınız gizli ise onayla butonu çıkması lazım.
            //3. Eğer siz gizli bir hesabı takip ettiyseniz ve kabul ettiyse mesaj olarak gözükmesi lazım. Bunları bildirimlerden yapmak daha mantıklı.
            //O yüzden bildirim atılacak user altına 3 maddeyi de koymak lazım. BildirimFriends diyelim. BildirimFriends'i real time yapmaya gerek yok. Arka planda çalışabilir.
            
            //BildirimFriends altında olacaklar -> Kimden, Kime, IstekTuru(Takip_izin, Takip_ettim, Takip_izin_ok, Tarih, Okundumu)
            //GetDb altına bağımsız çalışacağından dolayı tek bir metot eklesek yeterli gelecektir.
            
            //.child("users").child(UserDetail.id)
            
        if dataS.hasChild("users")
            {
                let dictUser = dataS.value! as! NSDictionary
                
                
                let allsnapShot = dataS.value! as! NSDictionary
                let getUsers = allsnapShot["users"] as! NSDictionary
                _ = getUsers.allKeys
                
                if let getUser = getUsers[UserDetail.id] as! NSDictionary?
                {
                    if let dictUserBildirimFriends = getUser["BildirimFriends"] as! NSDictionary?
                    {
                        let userFriendBildirims = dictUserBildirimFriends.allKeys
                        for friendBildirim in userFriendBildirims
                        {
                            if let singleNotif = dictUserBildirimFriends[friendBildirim] as! NSDictionary?
                            {
                                let varmi = self.likeCommentList.contains(where: { (ncl) -> Bool in
                                    ncl.bildirimId == friendBildirim as! String
                                })
                                if varmi == false
                                {
                                    if let okunmaDurumu = singleNotif["okunmaDurumu"] as! Bool?
                                    {
                                        if okunmaDurumu == false
                                        {
                                            let newNotify = NotifyFriends()
                                            newNotify.type = singleNotif["istekTuru"] as! String
                                            newNotify.kimden = singleNotif["kimden"] as! String
                                            newNotify.kime = singleNotif["kime"] as! String
                                            newNotify.bildirim_id = friendBildirim as! String
                                            newNotify.readingStatus = okunmaDurumu
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "dd.MM.yyyy"
                                            let resultDate = formatter.date(from: singleNotif["tarih"] as! String)
                                            newNotify.date = resultDate!
                                            if let getUser = getUsers[newNotify.kimden] as! NSDictionary?
                                            {
                                                if let getProfile = getUser["profile"] as! NSDictionary?
                                                {
                                                    let getProfilImagen = getProfile[newNotify.kimden] as! NSDictionary
                                                    
                                                    if (getProfilImagen["ProfilResim"] as! String?) != nil
                                                    {
                                                        newNotify.profilImage = getProfilImagen["ProfilResim"] as! String
                                                    }
                                                    else
                                                    {
                                                        newNotify.profilImage = ""
                                                    }
                                                    
                                                    newNotify.userName = getProfilImagen["AdSoyad"] as! String
                                                }
                                            }
                                            
                                            let varmi = self.bildirimFriendList.contains(where: { (bildirimDurum) -> Bool in
                                                bildirimDurum.bildirim_id == newNotify.bildirim_id
                                            }) //Eklenen bir kullanıcının tekrar eklenmemesi için
                                            
                                            if varmi == false
                                            {
                                                self.bildirimFriendList.append(newNotify)
                                            }
                                            
                                            
                                            if self.bildirimFriendList.count > 0
                                            {
                                                self.btnFriends.setImage(UIImage(named: "Arkadas_var"), for: .normal)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //Bildirimler getirilecek.
                    if let singleUserNotifications = getUser["bildirimler"] as! NSDictionary?
                    {
                        let userNotifications = singleUserNotifications.allKeys
                        for user_notif in userNotifications
                        {
                            //["Kimden" : UserDetail.id, "Kime" : userID, "Tarih" : result, "Tip" : "L", "Okunma" : "false"]
                            if let singleNotif = singleUserNotifications[user_notif] as! NSDictionary?
                            {
                                let varmi = self.likeCommentList.contains(where: { (ncl) -> Bool in
                                    ncl.bildirimId == user_notif as! String
                                })
                                
                                if varmi == false
                                {
                                    if singleNotif["Okunma"] as! String == "false"
                                    {
                                        let newNotify = NotifyCommentLikes()
                                        newNotify.type = singleNotif["Tip"] as! String
                                        newNotify.user = singleNotif["Kimden"] as! String
                                        newNotify.kime = singleNotif["Kime"] as! String
                                        newNotify.bildirimId = user_notif as! String
                                        
                                        newNotify.readingStatus = Bool(singleNotif["Okunma"] as! String) ?? false
                                        newNotify.id = singleNotif["ID"] as! String
                                        
                                        let tarihFormatted = singleNotif["Tarih"] as! String
                                        
                                        newNotify.date = tarihFormatted
                                        
                                        if dataS.hasChild("users")
                                        {
                                            let allsnapShot = dataS.value! as! NSDictionary
                                            let getUsers = allsnapShot["users"] as! NSDictionary
                                            _ = getUsers.allKeys
                                            
                                            if let getUser = getUsers[newNotify.user] as! NSDictionary?
                                            {
                                                if let getProfile = getUser["profile"] as! NSDictionary?
                                                {
                                                    let getProfilImagen = getProfile[newNotify.user] as! NSDictionary
                                                    
                                                    if let getProfilImage = getProfilImagen["ProfilResim"] as! String?
                                                    {
                                                        newNotify.profilImage = getProfilImage
                                                    }
                                                    else
                                                    {
                                                        newNotify.profilImage = ""
                                                    }
                                                    
                                                    newNotify.userName = getProfilImagen["AdSoyad"] as! String
                                                }
                                            }
                                        }
                                        
                                        let varmi = self.likeCommentList.contains(where: { (bildirimDurum) -> Bool in
                                            bildirimDurum.bildirimId == newNotify.bildirimId
                                        }) //Eklenen bir kullanıcının tekrar eklenmemesi için
                                        
                                        if varmi == false
                                        {
                                            self.likeCommentList.append(newNotify)
                                        }
                                        
                                        if self.likeCommentList.count > 0
                                        {
                                            self.btnNotifications.setImage(UIImage(named: "Bildirim_var"), for: .normal)
                                        }
                                        else
                                        {
                                            self.btnNotifications.setImage(UIImage(named: "Bildirim_yok"), for: .normal)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if let dictFollowing = getUser["Following"] as! NSDictionary?
                    {
                    let postID = dictFollowing.allKeys
                    for id in postID //Buradaki ID'ler UserID'lere tekabül etmektedir.
                    {
                        let followingID = dictFollowing[id] as! NSDictionary
                        let onayGereklimiActiveUserFollowings = followingID["onaygerekli"] as! String
                        _ = TakipListe()
                        
                        let varmi = self.takipEdilenListe.contains(where: { (takipEdilen) -> Bool in
                            takipEdilen == id as! String
                        }) //Eklenen bir kullanıcının tekrar eklenmemesi için
                        
                        if varmi == false
                        {
                            if onayGereklimiActiveUserFollowings == "false" //Kullanıcılara bakılır. Eğer varsa ve
                            {
                                self.takipEdilenListe.append(id as! String)
                                //Alınan kullanıcıların takip edilip edilmemesi gerektiği giriş yapılan kullanıcıya ait olduğundan kullanıcılar tek tek kontrol edilir.
                            }
                        }
                    }
                    }
                }
            }

            
            
        
            if self.takipEdilenListe.count > 0
            {
                //Takip edilenlerin altında sharedEvent listesi alınır.
                //Tüm shared olanlar alınır - ve takip edilenlerin ID'leri ile kıyaslanıp paylaşılan eventID'lar alınır.
                _ = databaseReference.child("users").observe(DataEventType.childAdded, with: { (data) in
                    if data.hasChild("Shared") //Tüm shared olanlar alınır.
                    {
                        let valuesShared = data.value! as! NSDictionary
                        let postSh = valuesShared["Shared"] as! NSDictionary
                        let postID = postSh.allKeys
                        for id in postID
                        {
                            let sharedID = postSh[id] as! NSDictionary
                            let shUserID = sharedID["userID"] as! String
                            
                            if shUserID == UserDetail.id
                            {
                                let varmi = self.sharedIDs.contains(where: { (share) -> Bool in
                                    share == shUserID
                                }) //Eklenen bir kullanıcının tekrar eklenmemesi için
                                
                                if varmi == false
                                {
                                    if self.takipEdilenListe.contains(shUserID )
                                    {
                                        let shEventID = sharedID["eventID"] as! String
                                        
                                        self.sharedIDs.append(shEventID)
                                    }
                                }
                            }
                        }
                    }
                
                //Tüm eventler içerisindede detaylar gösterilir.
                    if self.sharedIDs.count > 0
                    {
                        _ = databaseReference.observe(DataEventType.value) { (snapshot) in
                        
                        //.child("users").child(userID).child("Event")
                        if snapshot.hasChild("users")
                        {
                            let values = snapshot.value! as! NSDictionary
                            let post = values["users"] as! NSDictionary
                            let postID = post.allKeys
                            
                            
//                            if gl_Load == false
//                            {
//                                self.Etkinliklerim.removeAll()
//                            }
                            
                            var sehir = String()
                            var ilce = String()
                            var userProfileImage = String()
                            var profilIsletmemi = false
                            var userName = String() //Yeni Kayıt Olanlara farklı isim vermek gerekebilir.
                            for userID in postID //Shared altındakiler farklı userlara ait olacağından hepsi alınır.
                            {
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
                                        userName = UserDetail.username as! String //OpenID harici kullanıcılar yeni üye olurken ad soyad girilmesi gerek
                                    }
                                }
                                
                                if let singleEvent = singleUser["Event"] as! NSDictionary? //Event alındı. Alındaki main klasörüne ulaşılacak.
                                {
                                    //Burada tüm eventler alınacak, altındaki her event için event grouplarından en ucuz olan getirilecek.
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
                                            if self.sharedIDs.contains(id as! String) { //Paylaşılan event arasındaysa ekle.
                                            //Event->Main Altındaki Like klasörü alınır.
                                            if let singlePost = singleMain[id] as! NSDictionary?
                                            {
                                                
                                                if let getLikes = singlePost["Like"] as! NSDictionary?
                                                {
                                                    let getUserLikes = getLikes.allKeys
                                                    for liker in getUserLikes
                                                    {
                                                        if let singleLiker = getLikes[liker] as! NSDictionary?
                                                        {
                                                            self.postLikesCount = self.postLikesCount + 1
                                                            if liker as! String == UserDetail.id
                                                            {
                                                                self.ImLiker = true
                                                            }
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    self.ImLiker = false
                                                }
                                                
                                                if snapshot.hasChild("Messages")
                                                {
                                                    //let valuesMessages = snapshot.value! as! NSDictionary
                                                    let postMessages = values["Messages"] as! NSDictionary
                                                    let postIDMessages = postMessages.allKeys
                                                    
                                                    for eventID in postIDMessages //Tüm eventlar alınır.
                                                    {
                                                        
                                                        let getEventID = eventID as! String
                                                        if getEventID == id as! String
                                                        {
                                                            if let getComments = postMessages[getEventID] as! NSDictionary?
                                                            {
                                                                let getCommentsKeys = getComments.allKeys
                                                                for _ in getCommentsKeys
                                                                {
                                                                    self.postCommentsCount =  self.postCommentsCount + 1
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
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
                                                    let etResmi = singlePost["Resim1"] as? String ?? "https://image.istanbul.net.tr/uploads/2018/12/event/merhaba-770x470.jpg"
                                                    let etResmi2 = singlePost["Resim2"] as? String
                                                    let etResmi3 = singlePost["Resim3"] as? String
                                                    let etResmi4 = singlePost["Resim4"] as? String
                                                    
                                                    let usID = singlePost["UserID"] as! String //singlePost["UserID"] as! String
                                                    let etkSuresizmi = singlePost["Suresiz"] as! String
                                                    let enUcuz = self.eventBiletGroupList.first(where: { (eventBiletVarMi) -> Bool in
                                                        eventBiletVarMi.EventID == Eventid
                                                    })
                                                    
                                                    let myEtkinlik = MainEtkinlik(etkinlik_Adi: etAdi, etkinlik_Tarihi: etTarihi, Etkinlik_Saati: etSaati, etkinlik_Aciklama: etAc, etkinlik_Suresiz: etkSuresizmi, etkinlik_Adresi: etAd, etkinlik_Ucretsiz: self.etkinlikUcretsizDurum, etkinlik_Kategorisi: "Bos", etkinlik_resmi: etResmi, etkinlik_resmi2: etResmi2!, etkinlik_resmi3: etResmi3!, etkinlik_resmi4: etResmi4!, etkinlik_konum: konumBilgileri , etkinlik_ucret: String(enUcuz!.EnUcuzBilet), etkinlik_UserID: usID, etkinlik_id: id as! String, profil_Resim: userProfileImage, user_Name : userName, begeni_Sayisi: String(self.postLikesCount), ben_Varmiyim: self.ImLiker, comment_Count: self.postCommentsCount, profil_Isletmemi: profilIsletmemi )
                                                    
                                                    
                                                    self.Etkinliklerim.append(myEtkinlik)
                                                }
                                                
                                                self.postLikesCount = 0
                                                self.postCommentsCount = 0
                                                self.ImLiker = false
                                            }
                                            //Diğeri buraya konacak
                                            }
                                        }
                                    }
                                }
                                
                            }
                            //self.Etkinliklerim = self.Etkinliklerim.reversed()
                            self.Etkinliklerim = self.Etkinliklerim.sorted(by: { (MainEtkinlik1, MainEtkinlik2) -> Bool in
                                if MainEtkinlik1.etkinlikTarihi > MainEtkinlik2.etkinlikTarihi
                                {
                                    return true
                                }
                                else
                                {
                                    return false
                                }
                            })
                            if gl_Load == true
                            {
                                self.tblViewEvents.isHidden = false
                                self.tblViewEvents.reloadData()
                            }
                            self.tblNotifications.reloadData()
                            self.tblViewFriendBildirimler.reloadData()
                            
                            
                            //viewShared_Ok
                            if self.Etkinliklerim.count > 0
                            {
                              self.viewShared_Ok.isHidden = true
                              self.tblViewEvents.isHidden = false
                            }
                            else
                            {
                              self.viewShared_Ok.isHidden = false
                              self.tblViewEvents.isHidden = true
                              self.viewShared_OkMessage.text = "Henüz paylaştığınız bir etkinlik bulunmuyor"
                            }
                            
                            SVProgressHUD.dismiss()
                        }
                        else
                        {
                            //Buraya ekranda birşey gösterilmeyecek...
                            self.tblViewEvents.isHidden = true
                            self.tblNotifications.isHidden = true
                            self.tblViewFriendBildirimler.isHidden = true
                            SVProgressHUD.dismiss()
                        }
                        }
                    }
                    else
                    {
                        //Buraya ekranda sterilmeyecek...
                        self.tblViewEvents.isHidden = true
                        self.tblNotifications.isHidden = true
                        self.tblViewFriendBildirimler.isHidden = true
                        SVProgressHUD.dismiss()
                    }
            })
      }
      else
      {
        //Buraya ekranda birşey gösterilmeyecekself.tblViewEvents.isHidden = true
      SVProgressHUD.dismiss()
            }
    }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblNotifications
        {
            return likeCommentList.count
        }
        else if tableView == self.tblViewEvents
        {
            return Etkinliklerim.count
        }
        else
        {
            return bildirimFriendList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tblNotifications
        {
            return 60
        }
        else if tableView == self.tblViewEvents
        {
            return 300
        }
        else
        {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tblNotifications
        {
            let cell = tblNotifications.dequeueReusableCell(withIdentifier: "CellBegeni", for : indexPath) as! BegeniBildirimCell
            
            if likeCommentList.count > 0
            {
                if likeCommentList[indexPath.row].type == "L"
                {
                    cell.lblBildirimMessage.text = likeCommentList[indexPath.row].userName + " paylaştığın bir etkinliği beğendi"
                }
                else
                {
                    cell.lblBildirimMessage.text = likeCommentList[indexPath.row].userName + " paylaştığın bir etkinliğe yorum yaptı"
                }
                
                cell.layer.borderWidth = 0.2
                cell.layer.borderColor = UIColor.flatGray()?.cgColor
                
                cell.imgProfil.sd_setImage(with: URL(string : likeCommentList[indexPath.row].profilImage), completed: nil)
                
                
                let resim = likeCommentList[indexPath.row].profilImage
                if resim != ""
                {
                    cell.imgProfil.layer.cornerRadius = cell.imgProfil.frame.height / 2
                    cell.imgProfil.layer.masksToBounds = true
                    cell.imgProfil.contentMode = .scaleAspectFill
                    cell.imgProfil.layer.masksToBounds = true
                    
                    cell.imgProfil.sd_setImage(with: URL(string: resim)) { (img, err, cachType, url) in
                        if err != nil
                        {
                            cell.imgProfil.image = UIImage(named: "default_person")
                        }
                    }
                }
                else
                {
                    cell.imgProfil.image = UIImage(named: "default_person")
                }
                
            }
            //cell.imgEventImage.sd_setImage(with: URL(string : Etkinliklerim[indexPath.row].etkinlikResimi as! String), completed: nil)
            
            return cell
        }
        else if tableView == self.tblViewEvents
        {
           
            let cell = tblViewEvents.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! feedCell
            //Profil bilgileri konulacak
            //cell.lblProfilName =
            //cell.imgProfilImage
            
            if Etkinliklerim.count > 0
            {
                if gl_Load == true
                {
                cell.delegate = self
                //cell.lblEventDate.text = Etkinliklerim[indexPath.row].etkinlikTarihi as! String
                cell.lblEventname.text = Etkinliklerim[indexPath.row].etkinlikAdi
                //cell.lblKonum.text = Etkinliklerim[indexPath.row].etkinlikAdresi as! String
                cell.imgEventImage.sd_setImage(with: URL(string : Etkinliklerim[indexPath.row].etkinlikResimi ), completed: nil)
                
                cell.imageLink = Etkinliklerim[indexPath.row].etkinlikResimi
                cell.imgProfilImage.sd_setImage(with: URL(string: Etkinliklerim[indexPath.row].profilResim ), completed: nil)
                cell.viewDetay.backgroundColor = UIColor(white: 1, alpha: 0.5)
                
                cell.lblKonum.text = Etkinliklerim[indexPath.row].EtkinlikKonum
                
                cell.lblActiveUserIDHidden.text = Etkinliklerim[indexPath.row].EtkinlikUserID
                cell.viewDetay.layer.cornerRadius = 10
                //var Onayli = ""
                var Onayli = 0
                //Beğenileri eventlerin altına atacağız.
                
                    if String(Etkinliklerim[indexPath.row].benVarmiyim) == "true" //Gelen eğer beğenilmişse zaten beğeniden vazgeçilecek demektir.
                    {
                        cell.btnLikeTip.setImage(UIImage(named: "heart_voll"), for: .normal)
                        
                    }
                    else //Beğenilecekse eğer true'ya çekilir.
                    {
                        cell.btnLikeTip.setImage(UIImage(named: "heart_empty"), for: .normal)
                    }
                    cell.lblLikeCount.text = Etkinliklerim[indexPath.row].begeniSayisi
                
                if String(Etkinliklerim[indexPath.row].benVarmiyim) == "true" //Gelen eğer beğenilmişse zaten beğeniden vazgeçilecek demektir.
                {
                    Onayli = 0
                }
                else //Beğenilecekse eğer true'ya çekilir.
                {
                    Onayli = 1
                }
                
                cell.btnHeart.tag = Onayli
                //cell.btnHeart.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
                cell.lblCommentCount.text = String(Etkinliklerim[indexPath.row].commentCount)
                //cell.lblImLiker.text = Onayli
                
                cell.lblEventId.text = Etkinliklerim[indexPath.row].EtkinlikID
                cell.btnProfilName.setTitle(Etkinliklerim[indexPath.row].userName, for: .normal)
                cell.imgProfilImage.layer.cornerRadius = cell.imgProfilImage.frame.height / 2
                cell.lblEventUserID.text = Etkinliklerim[indexPath.row].EtkinlikUserID
                cell.imgProfilImage.layer.masksToBounds = true
                cell.imgProfilImage.contentMode = .scaleToFill
                cell.imgBrand.isHidden = !Etkinliklerim[indexPath.row].profilIsletmemi
                
                if Etkinliklerim[indexPath.row].etkinlikSuresiz == "true"
                {
                    cell.lblTarihAy.text = "Süresiz"
                    cell.lblTarihAyText.text = "Aktivite"
                }
                else
                {
                    cell.lblTarihAy.text = utilities.ChangeDateToDay(tarih: Etkinliklerim[indexPath.row].etkinlikTarihi)
                    cell.lblTarihAyText.text = utilities.ChangeDateToMonth(tarih: Etkinliklerim[indexPath.row].etkinlikTarihi)
                }
                
                }
            }
            return cell
        }
        else
        {
            
            let cellTakipEdilen = tblViewFriendBildirimler.dequeueReusableCell(withIdentifier: "cellTakip", for: indexPath) as! BildirimFriendCell
            
            
            if bildirimFriendList[indexPath.row].profilImage != ""
            {
                cellTakipEdilen.ingProfile.sd_setImage(with: URL(string: bildirimFriendList[indexPath.row].profilImage), completed: nil)
            }
            else
            {
                cellTakipEdilen.ingProfile.image = UIImage(named: "default_person")
            }
            
            //cellTakipEdilen.lblTakipEdilenHiddenTasiyici.text = takipEdilenlerim[indexPath.row].User_ID
            cellTakipEdilen.user_id = bildirimFriendList[indexPath.row].kimden
            cellTakipEdilen.index = indexPath
            
            cellTakipEdilen.layer.borderWidth = 0.2
            cellTakipEdilen.layer.borderColor = UIColor.flatGray()?.cgColor
            
            //Burası onayla butonu olacak.
            
            if bildirimFriendList[indexPath.row].type == BildirimTipi.Takip_izin
            {
                cellTakipEdilen.lblUserName.text = bildirimFriendList[indexPath.row].userName + " takip etme isteği gönderdi"
                cellTakipEdilen.btnOnayla.isHidden = false
            }
            else if bildirimFriendList[indexPath.row].type == BildirimTipi.Takip_ettim
            {
                cellTakipEdilen.lblUserName.text = bildirimFriendList[indexPath.row].userName + " sizi takip ediyor"
                cellTakipEdilen.btnOnayla.isHidden = true
            }
            else if bildirimFriendList[indexPath.row].type == BildirimTipi.Takip_izin_ok
            {
                cellTakipEdilen.lblUserName.text = bildirimFriendList[indexPath.row].userName + " takip etme isteğinizi onayladı"
                cellTakipEdilen.btnOnayla.isHidden = true
            }
            else
            {
                cellTakipEdilen.lblUserName.text = bildirimFriendList[indexPath.row].userName
            }
            
            return cellTakipEdilen
        }
       
    }
    
    var anaEtkinlik = MainEtkinlik.init(etkinlik_Adi: "", etkinlik_Tarihi: "", Etkinlik_Saati: "", etkinlik_Aciklama: "", etkinlik_Suresiz: "", etkinlik_Adresi: "", etkinlik_Ucretsiz: "", etkinlik_Kategorisi: "", etkinlik_resmi: "", etkinlik_resmi2: "", etkinlik_resmi3: "", etkinlik_resmi4: "", etkinlik_konum: "", etkinlik_ucret: "", etkinlik_UserID: "", etkinlik_id: "", profil_Resim: "", user_Name: "", begeni_Sayisi: "", ben_Varmiyim: false, comment_Count: 0, profil_Isletmemi: false)
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vw_sfeed_dfeed"
        {
            let destinationVC = segue.destination as! feedDetail

            destinationVC.etkinlikDetayResimLink = anaEtkinlik.etkinlikResimi
            destinationVC.etkinlikDetayAd = anaEtkinlik.etkinlikAdi
            destinationVC.etkinlikDetayBolge = anaEtkinlik.EtkinlikKonum
            destinationVC.etkinlikDetayTarih = anaEtkinlik.etkinlikTarihi
            destinationVC.etkinlikDetayAciklama = anaEtkinlik.etkinlikAciklama
            destinationVC.etkinlikDetayFiyat = anaEtkinlik.EtkinlikUcret
            destinationVC.etkinlikID = anaEtkinlik.EtkinlikID
            destinationVC.userID = anaEtkinlik.EtkinlikUserID
            destinationVC.etkinlikSuresizmi = Bool(anaEtkinlik.etkinlikSuresiz)!
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
    var resimList = [String]()
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tblNotifications
        {
            let getNotifEvent = Etkinliklerim.first { (MainEtkinlik) -> Bool in
                MainEtkinlik.EtkinlikID == likeCommentList[indexPath.row].id
            }
            anaEtkinlik.etkinlikAciklama = getNotifEvent!.etkinlikAciklama
            anaEtkinlik.etkinlikAdi = getNotifEvent!.etkinlikAdi
            anaEtkinlik.etkinlikResimi = getNotifEvent!.etkinlikResimi
            anaEtkinlik.EtkinlikKonum = getNotifEvent!.EtkinlikKonum
            anaEtkinlik.etkinlikTarihi = getNotifEvent!.etkinlikTarihi
            anaEtkinlik.etkinlikUcretsiz = getNotifEvent!.etkinlikUcretsiz
            anaEtkinlik.EtkinlikUserID = getNotifEvent!.EtkinlikUserID
            anaEtkinlik.EtkinlikID = getNotifEvent!.EtkinlikID
            anaEtkinlik.etkinlikSuresiz = getNotifEvent!.etkinlikSuresiz
            anaEtkinlik.profilResim = getNotifEvent!.profilResim
            anaEtkinlik.userName = getNotifEvent!.userName
            anaEtkinlik.etkinlikResimi2 = getNotifEvent!.etkinlikResimi2
            anaEtkinlik.etkinlikResimi3 = getNotifEvent!.etkinlikResimi3
            anaEtkinlik.etkinlikResim4 = getNotifEvent!.etkinlikResim4
            anaEtkinlik.profilIsletmemi = getNotifEvent!.profilIsletmemi
            
            let enUcuz = self.eventBiletGroupList.first(where: { (eventBiletVarMi) -> Bool in
                eventBiletVarMi.EventID == getNotifEvent!.EtkinlikID
            })
            
            anaEtkinlik.EtkinlikUcret = String(enUcuz!.EnUcuzBilet)
            
            let dataRef = Database.database().reference()
            
            let commentNotify = ["Kimden" : likeCommentList[indexPath.row].user , "Kime" : likeCommentList[indexPath.row].kime , "Tarih" : likeCommentList[indexPath.row].date , "Tip" : likeCommentList[indexPath.row].type , "Okunma" : "true", "ID" : likeCommentList[indexPath.row].id ]
            dataRef.child("users").child(likeCommentList[indexPath.row].kime).child("bildirimler").child(likeCommentList[indexPath.row].bildirimId).setValue(commentNotify)
            {
                (error, reference) in
                if error == nil
                {
                    self.performSegue(withIdentifier: "vw_sfeed_dfeed", sender: nil)
                }
                else
                {
                    self.performSegue(withIdentifier: "vw_sfeed_dfeed", sender: nil)
                }
            }
        }
        else if tableView == self.tblViewEvents
        {
            anaEtkinlik.etkinlikAciklama = Etkinliklerim[indexPath.row].etkinlikAciklama
            anaEtkinlik.etkinlikAdi = Etkinliklerim[indexPath.row].etkinlikAdi
            anaEtkinlik.etkinlikResimi = Etkinliklerim[indexPath.row].etkinlikResimi
            anaEtkinlik.EtkinlikKonum = Etkinliklerim[indexPath.row].EtkinlikKonum
            anaEtkinlik.etkinlikTarihi = Etkinliklerim[indexPath.row].etkinlikTarihi
            anaEtkinlik.EtkinlikUcret = Etkinliklerim[indexPath.row].EtkinlikUcret
            anaEtkinlik.EtkinlikUserID = Etkinliklerim[indexPath.row].EtkinlikUserID
            anaEtkinlik.EtkinlikID = Etkinliklerim[indexPath.row].EtkinlikID
            anaEtkinlik.etkinlikSuresiz = Etkinliklerim[indexPath.row].etkinlikSuresiz
            anaEtkinlik.profilResim = Etkinliklerim[indexPath.row].profilResim
            anaEtkinlik.userName = Etkinliklerim[indexPath.row].userName
            anaEtkinlik.etkinlikResimi2 = Etkinliklerim[indexPath.row].etkinlikResimi2
            anaEtkinlik.etkinlikResimi3 = Etkinliklerim[indexPath.row].etkinlikResimi3
            anaEtkinlik.etkinlikResim4 = Etkinliklerim[indexPath.row].etkinlikResim4
            anaEtkinlik.profilIsletmemi = Etkinliklerim[indexPath.row].profilIsletmemi
            performSegue(withIdentifier: "vw_sfeed_dfeed", sender: nil)
        }
        else
        {
            StringActiveUserID = bildirimFriendList[indexPath.row].kimden
            self.tabBarController!.reloadInputViews()
            self.performSegue(withIdentifier: "SharedFeed_VProfil", sender: nil)
        }
        
    }
    
    func callSegueFromCell(myData dataobject : AnyObject) {
        StringActiveUserID = dataobject as! String
        
        self.tabBarController!.reloadInputViews()
        
        self.performSegue(withIdentifier: "SharedFeed_VProfil", sender: nil)
    }
    
    func callCommentsFromCell(eventID takeEventID: AnyObject, eventUserID: AnyObject) {
        StringActiveEventID = takeEventID as! String
        StringActiveEventUserID = eventUserID as! String
        
        self.performSegue(withIdentifier: "SharedToComments", sender: nil)
    }
    
    func didSharedSocial(eventID: String, eventName: String) {
        let sharedString = eventName + " Bu etkinliğe göz atmak ister misin : " + webSiteName + "/" + eventID //Buraya item ID'si gelecek.
        
        let activityController = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error) in
            if completed {
                print("completed")
            } else {
                print("cancled")
            }
        }
        
        present(activityController, animated: true) {
            print("presented")
        }
        //        //webSiteName
    }
    
    
    func didShareInApp(imageName: String, eventName: String, eventID : String, eventUserID : String) {
        let popOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shared_popup") as! SharedList
        
        //globale taşıyoruz.
        selectedEventName = eventName
        selectedEventImage = imageName
        selectedEventID = eventID
        selectedEventUserId = eventUserID
        
        self.addChild(popOver)
        popOver.view.frame = self.view.frame
        self.view.addSubview(popOver.view)
        popOver.didMove(toParent: self)
    }
    
    func didSikayet(eventID : String, eventUserID : String)
    {
        let popOverSikayet = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sb_sikayet") as! Sikayet
        selectedEventID = eventID
        selectedEventUserId = eventUserID
        
        self.addChild(popOverSikayet)
        popOverSikayet.view.frame = self.view.frame
        self.view.addSubview(popOverSikayet.view)
        popOverSikayet.didMove(toParent: self)
        //sb_sikayet
    }
    
    @IBAction func btnMain_Click(_ sender: UIButton) {
        tblNotifications.isHidden = true
        tblViewEvents.isHidden = false
        tblViewFriendBildirimler.isHidden = true
        
        //viewShared_Ok
        if self.Etkinliklerim.count > 0
        {
            viewShared_Ok.isHidden = true
             tblViewEvents.isHidden = false
        }
        else
        {
            viewShared_Ok.isHidden = false
             tblViewEvents.isHidden = true
            viewShared_OkMessage.text = "Henüz paylaştığınız bir etkinlik bulunmuyor"
        }
        
        
        if likeCommentList.count > 0
        {
            btnNotifications.setImage(UIImage(named: "Bildirim_var"), for: .normal)
        }
        else
        {
            btnNotifications.setImage(UIImage(named: "Bildirim_yok"), for: .normal)
        }
        
        if self.bildirimFriendList.count > 0
        {
            self.btnFriends.setImage(UIImage(named: "Arkadas_var"), for: .normal)
        }
        else
        {
            self.btnFriends.setImage(UIImage(named: "Arkadas_yok"), for: .normal)
        }
        
        btnFeedMain.setImage(UIImage(named: "Kesfet_Aktif"), for: .normal)
        
    }
    
    @IBAction func btnBildirim_Click(_ sender: UIButton) {
        
        tblNotifications.isHidden = false
        tblViewEvents.isHidden = true
        tblViewFriendBildirimler.isHidden = true
        if likeCommentList.count > 0
        {
            btnNotifications.setImage(UIImage(named: "Bildirim_var_aktif"), for: .normal)
        }
        else
        {
            btnNotifications.setImage(UIImage(named: "Bildirim_yok_aktif"), for: .normal)
        }
        
        //viewShared_Ok
        if self.bildirimFriendList.count > 0
        {
            viewShared_Ok.isHidden = true
        }
        else
        {
            viewShared_Ok.isHidden = false
            viewShared_OkMessage.text = "Henüz Bildiriminiz Bulunmuyor"
        }
        
        
        btnFeedMain.setImage(UIImage(named: "Kesfet_Pasif"), for: .normal)
        if self.bildirimFriendList.count > 0
        {
            self.btnFriends.setImage(UIImage(named: "Arkadas_var"), for: .normal)
        }
        else
        {
            self.btnFriends.setImage(UIImage(named: "Arkadas_yok"), for: .normal)
        }
        
        //viewShared_Ok
        if self.likeCommentList.count > 0
        {
            viewShared_Ok.isHidden = true
            tblNotifications.isHidden = false
        }
        else
        {
            viewShared_Ok.isHidden = false
            tblNotifications.isHidden = true
            viewShared_OkMessage.text = "Henüz Bildiriminiz Bulunmuyor"
        }
    }
    
    @IBAction func btnFriends_Click(_ sender: UIButton) {
        tblNotifications.isHidden = true
        tblViewEvents.isHidden = true
        tblViewFriendBildirimler.isHidden = false
        
        if likeCommentList.count > 0
        {
            btnNotifications.setImage(UIImage(named: "Bildirim_var"), for: .normal)
        }
        else
        {
            btnNotifications.setImage(UIImage(named: "Bildirim_yok"), for: .normal)
        }
        btnFeedMain.setImage(UIImage(named: "Kesfet_Pasif"), for: .normal)
        if self.bildirimFriendList.count > 0
        {
            self.btnFriends.setImage(UIImage(named: "Arkadas_var_aktif"), for: .normal)
        }
        else
        {
            self.btnFriends.setImage(UIImage(named: "Arkadas_yok_aktif"), for: .normal)
        }
        
        //viewShared_Ok
        if self.bildirimFriendList.count > 0
        {
            viewShared_Ok.isHidden = true
            tblViewFriendBildirimler.isHidden = false
        }
        else
        {
            viewShared_Ok.isHidden = false
            tblViewFriendBildirimler.isHidden = true
            viewShared_OkMessage.text = "Henüz Bildiriminiz Bulunmuyor"
        }
    }

}

protocol MyCustomCellDelegator {
    func callSegueFromCell(myData dataobject : AnyObject)
    
    func callCommentsFromCell(eventID takeEventID : AnyObject, eventUserID takeUserID : AnyObject)
    
    func didSharedSocial(eventID : String, eventName : String)
    
    func didShareInApp(imageName : String, eventName : String, eventID : String, eventUserID : String)
    
    func didSikayet(eventID : String, eventUserID : String)
    
}
