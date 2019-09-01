//
//  Chat.swift
//  FirebaseDemo
//
//  Created by macbookpro on 18.03.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class Chat: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MessageDelegate {

    @IBOutlet weak var lblTakerUserID: UILabel!
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var eventBiletGroupList = [TicketBiletGroup]()
    var biletUcuzFiyat = 3000.99
    var etkinlikUcretsizDurum = "false"
    
    var topButton = UIButton()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        
        configureTableView()
        
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messageArray[indexPath.row].EventImage != ""
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventMessageCell", for: indexPath) as! EventMessageCell
            
            cell.lblEventAdi.text = messageArray[indexPath.row].messageBody
            print(messageArray[indexPath.row].EventImage)
            
            cell.eventID = messageArray[indexPath.row].EventID
            cell.eventUserID = messageArray[indexPath.row].EventUserID
            cell.imageEvent.sd_setImage(with: URL(string: messageArray[indexPath.row].EventImage), completed: nil)
            cell.imageEvent.layer.cornerRadius = 10
            cell.btnImage.layer.cornerRadius = 10
            cell.messageBacckGround.layer.cornerRadius = 10
            cell.delegate = self
            if messageArray[indexPath.row].userID == UserDetail.id
            {
                cell.messageBacckGround.backgroundColor =  UIColor.flatWhite()
            }
            else
            {
                cell.messageBacckGround.backgroundColor =  UIColor.flatGray()
            }
            
            var lv_profilResmi = messageArray[indexPath.row].profileImage
            
            if  lv_profilResmi != ""
            {
                cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.height / 2
                cell.imgProfile.layer.masksToBounds = true
                cell.imgProfile.contentMode = .scaleAspectFill
                
                cell.imgProfile.sd_setImage(with: URL(string: lv_profilResmi )) { (image, error, cacheType, url) in
                    if error != nil
                    {
                        cell.imgProfile.image = UIImage(named: "default_person")
                    }
                }
            }
            else
            {
                cell.imgProfile.image = UIImage(named: "default_person")
            }
            lv_profilResmi = ""
            return cell
        }
        else
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            
            cell.messageBody.text = messageArray[indexPath.row].messageBody
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.lblTarih.text = messageArray[indexPath.row].tarih
            var lv_profilResmi = messageArray[indexPath.row].profileImage
            
            if messageArray[indexPath.row].userID == UserDetail.id
            {
                cell.messageBackground.backgroundColor =  UIColor.flatSkyBlue()
            }
            else
            {
                cell.messageBackground.backgroundColor =  UIColor.flatMint()
            }
            
            
            
            if  lv_profilResmi != ""
            {
                cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height / 2
                cell.avatarImageView.layer.masksToBounds = true
                cell.avatarImageView.contentMode = .scaleAspectFill
                
                
                
                cell.avatarImageView.sd_setImage(with: URL(string: lv_profilResmi )) { (image, error, cacheType, url) in
                    if error != nil
                    {
                        cell.avatarImageView.image = UIImage(named: "default_person")
                    }
                }
            }
            else
            {
                cell.avatarImageView.image = UIImage(named: "default_person")
            }
            lv_profilResmi = ""
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if messageArray[indexPath.row].EventImage != ""
        {
            return 151
        }
        else
        {
            return 82
        }
    }
    
    var anaEtkinlik = MainEtkinlik.init(etkinlik_Adi: "", etkinlik_Tarihi: "", Etkinlik_Saati: "", etkinlik_Aciklama: "", etkinlik_Suresiz: "", etkinlik_Adresi: "", etkinlik_Ucretsiz: "", etkinlik_Kategorisi: "", etkinlik_resmi: "", etkinlik_resmi2: "", etkinlik_resmi3: "", etkinlik_resmi4: "", etkinlik_konum: "", etkinlik_ucret: "", etkinlik_UserID: "", etkinlik_id: "", profil_Resim: "", user_Name: "", begeni_Sayisi: "", ben_Varmiyim: false, comment_Count: 0, profil_Isletmemi: false)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //satırı seçtiğimiz zaman ilgili veri setini doldurmuş oluyoruz, prepare metodunda da perform segue ile gittiği metoda hazırlık yapmış oluyoruz.
        if segue.identifier == "vw_chat_fdetail"
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
    
    
    
    
    func getEventFromServer(eventID : String, eventUserId : String)
    {
        let databaseReference = Database.database().reference()
        
        //Tüm eventleri göstersin
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
                    let lv_EventUserID = userID as! String
                    
                    if eventUserId == lv_EventUserID
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
                                    
                                    if eventID == Eventid
                                    {
                                        //Event->Main Altındaki Like klasörü alınır.
                                        if let singlePost = singleMain[id] as! NSDictionary?
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
                                                let usID = singlePost["UserID"] as! String //singlePost["UserID"] as! String
                                                
                                                let enUcuz = self.eventBiletGroupList.first(where: { (eventBiletVarMi) -> Bool in
                                                    eventBiletVarMi.EventID == Eventid
                                                })
                                            
                                            //perform segue ile gidecek olan anaetkinliki dolduruyoruz.
                                            self.anaEtkinlik = MainEtkinlik(etkinlik_Adi: etAdi, etkinlik_Tarihi: etTarihi, Etkinlik_Saati: etSaati, etkinlik_Aciklama: etAc, etkinlik_Suresiz: etkSuresizmi, etkinlik_Adresi: etAd, etkinlik_Ucretsiz: self.etkinlikUcretsizDurum, etkinlik_Kategorisi: "Bos", etkinlik_resmi: etResmi, etkinlik_resmi2: etResmi2, etkinlik_resmi3: etResmi3, etkinlik_resmi4: etResmi4, etkinlik_konum: konumBilgileri , etkinlik_ucret: String(enUcuz!.EnUcuzBilet), etkinlik_UserID: usID, etkinlik_id: Eventid, profil_Resim: userProfileImage, user_Name : userName, begeni_Sayisi: "0", ben_Varmiyim: false, comment_Count: 0, profil_Isletmemi: profilIsletmemi )
                                            
                                        }
                                        self.performSegue(withIdentifier: "vw_chat_fdetail", sender: nil)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //TODO: Declare configureTableView here:
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }

    //MARK: - TextField Delegate Methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        if StringActiveUserID != "" || StringActiveUserID != nil
        {
            //Chat yazışmaları chat->userID1->UserId2->UId1...UId2->Mesaj Detayı Olarak Kaydedilir.
            let databaseReference = Database.database().reference()
            var chatDB = DatabaseReference()
            var flag_load = false
            
            _ = databaseReference.child("chat").child(StringActiveUserID).child(UserDetail.id).observe(.value) { (data) in
                
                if flag_load == false
                {
                   flag_load = true
                    //1. Ben B kullanıcısıysam ve A kişisiyle yazışacaksam eğer, öncelikle A altında B var mı diye bakılır.
                    if data.exists()
                    {
                        //varsa eğer mesaj buraya yazılır.
                        chatDB = Database.database().reference().child("chat").child(StringActiveUserID).child(UserDetail.id)
                    }
                    else
                    {
                        //2. Yoksa eğer B altına A yazılır.
                        chatDB = Database.database().reference().child("chat").child(UserDetail.id).child(StringActiveUserID )
                    }
                    //var calendar =
                    
                    let date = Date()
                    let formatter = DateFormatter()
                    
                    formatter.dateFormat = "dd.MM.yyyy h:s"
                    let result = formatter.string(from: date)
                    
                    let messageDictionary = ["Sender": UserDetail.adsoayd,
                                             "MessageBody": self.messageTextfield.text!, "Tarih" : result , "UserID" : UserDetail.id]
                    
                    
                    chatDB.childByAutoId().setValue(messageDictionary) {
                        (error, reference) in
                        
                        if error != nil {
                            print(error!)
                        }
                        else {
                            print("Message saved successfully!")
                        }
                        
                        self.messageTextfield.isEnabled = true
                        self.sendButton.isEnabled = true
                        self.messageTextfield.text = ""
                    }
                    
                    self.configureTableView()
                    self.messageTableView.reloadData()
                }
        }
        }
    }
    
    @IBAction func btnGeri(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = false
         self.dismiss(animated: true, completion: nil)
    }
    
    
    func retrieveMessages() {

        if StringActiveUserID != "" || StringActiveUserID != nil
        {
            var chatDB = DatabaseReference()
            //
            let databaseReference = Database.database().reference()
            var flag_load_save = false
            self.configureTableView()
            self.messageTableView.reloadData()
            _ = databaseReference.child("chat").child(StringActiveUserID).child(UserDetail.id).observe(.value) { (data) in
                if flag_load_save == false
                {
                    flag_load_save = true
                    
                    //1. Ben B kullanıcısıysam ve A kişisiyle yazışacaksam eğer, öncelikle A altında B var mı diye bakılır.
                    if data.exists()
                    {
                        chatDB = Database.database().reference().child("chat").child(StringActiveUserID).child(UserDetail.id)
                    }
                    else
                    {
                        chatDB = Database.database().reference().child("chat").child(UserDetail.id).child(StringActiveUserID )
                    }
                    chatDB.observe(.childAdded) { (snapshot) in
                        
                        let snapshotValue = snapshot.value as! Dictionary<String,String>
                        let text = snapshotValue["MessageBody"]!
                        let sender = snapshotValue["Sender"]!
                        let tarih = snapshotValue["Tarih"]!
                        let UserID = snapshotValue["UserID"]!
                        
                        let message = Message()
                        message.messageBody = text
                        message.sender = sender
                        message.tarih = tarih
                        message.userID = UserID
                        
                        if let UserImage = snapshotValue["EventImage"]
                        {
                            message.EventImage = UserImage
                        }
                        
                        if let eventID = snapshotValue["EventID"]
                        {
                            message.EventID = eventID
                        }
                        
                        if let eventUserID = snapshotValue["EventUserID"]
                        {
                            message.EventUserID = eventUserID
                        }
                        
                        let databaseReference = Database.database().reference()
                        databaseReference.child("users").child(UserID).child("profile").child(UserID).observe(DataEventType.value, with: { (data) in
                            if data.exists()
                            {
                                
                                let value = data.value as? NSDictionary
                                
                                message.profileImage = value?["ProfilResim"] as? String ?? ""
                            }
                            self.messageArray.append(message)
                            self.configureTableView()
                            self.messageTableView.reloadData()
                        })
                    }
                }
            }
        }
    }
}



