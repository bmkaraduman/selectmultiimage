//
//  feedDetail.swift
//  FirebaseDemo
//
//  Created by macbookpro on 24.12.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseDatabase
import SVProgressHUD
import MapKit
import CoreLocation
import CoreData

var moreFriendList = [moreFriends]()


class feedDetail: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    @IBOutlet weak var lblTarih: UILabel!
    
    @IBOutlet weak var lblFiyat: UILabel!
    
    @IBOutlet weak var lblEtkAdi: UITextView!
    
    @IBOutlet weak var lblEtkinlikBolge: UILabel!
    
    @IBOutlet weak var txtEtkinlikAciklama: UITextView!
    
    @IBOutlet weak var txtOyunYeri: UITextField!
    
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    @IBOutlet weak var ViewFirst: UIView!
        
    @IBOutlet weak var ViewSecond: UIView!
    
    @IBOutlet weak var btnSatinAlmaSayfasiGit: UIButton!
    
    @IBOutlet weak var btnProfilImage: UIButton!
    @IBOutlet weak var btnProfilText: UIButton!
    
    @IBOutlet weak var Katilan1: UIButton!
    @IBOutlet weak var Katilan2: UIButton!
    @IBOutlet weak var Katilan3: UIButton!
    @IBOutlet weak var Katilan4: UIButton!
    @IBOutlet weak var Katilan5: UIButton!
    
    @IBOutlet weak var btnMoreFriends: UIButton!
    
    @IBOutlet weak var txtEtkinlikGun: UILabel!
    @IBOutlet weak var txtEtkinlikAy: UILabel!
    
    @IBOutlet weak var imgProfileBrand: UIImageView!
    
    var pickerViewBiletYerleri = UIPickerView()
    
    var etkinlikDetayResimLink = String()
    var etkinlikDetayFiyat = String()
    var etkinlikDetayTarih = String()
    var etkinlikDetayAd = String()
    var etkinlikDetayBolge = String()
    var etkinlikDetayAciklama = String()
    var etkinlikSuresizmi = Bool()
    var requestCLLocation = CLLocation()
    var etkinlikSahibiImageURL = String()
    var etkinlikSahibiUser = String()
    var profilIsletmemi = Bool()
    
    @IBOutlet weak var collectionView: UIImageView!
    
    @IBOutlet weak var lblEtkinlikKatilimciYok: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewControl: UIView!
    
    
    var etkinlikID = String()
    var userID = String() //Bu userID'nin analisteden gelmesi gerekiyor.
    var lv_ticketID = String()
    
    @IBOutlet weak var lblKalanKoltukSayisi: UILabel!
    var utilities = Utilities()
    var enlem = Double()
    var boylam = Double()
    
    var effect : UIVisualEffect!
    
    var eventGroups = [EventGroup]()
    var biletSayisiGroupCL = [BiletSayisiCL]()
    
    var yer = String()
    var fiyat = String()
    var ucretsizDurum = String()
    
    var isletmemi = String()
    
    var eventUserID = String()
    
    @IBOutlet weak var lblSeciliFiyat: UILabel!
    
    @IBOutlet weak var viewArkadaslar: UIView!
    
    @IBOutlet var selectChairView: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    @IBOutlet var viewHarita: UIView!
    
    var resimler = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moreFriendList = [moreFriends]()
        effect = visualEffect.effect
        visualEffect.effect = nil
        visualEffect.isHidden = true
        selectChairView.layer.cornerRadius = 10
        viewHarita.layer.cornerRadius = 10
        pickerViewBiletYerleri.delegate = self
        pickerViewBiletYerleri.dataSource = self
        
        self.tabBarController?.tabBar.isHidden = false
        
        viewArkadaslar.layer.cornerRadius = 10
        txtEtkinlikAciklama.layer.cornerRadius = 10
        
        imgProfileBrand.isHidden = !profilIsletmemi

        btnProfilImage.sd_setImage(with: URL(string: etkinlikSahibiImageURL), for: .normal, completed: nil)
        
        btnProfilText.setTitle(etkinlikSahibiUser, for: .normal) 
        
        btnProfilImage.layer.cornerRadius = btnProfilImage.frame.height / 2
        btnProfilImage.layer.masksToBounds = true
        
        Katilan1.layer.cornerRadius = Katilan1.frame.height / 2
        Katilan1.layer.masksToBounds = true
        
        Katilan2.layer.cornerRadius = Katilan2.frame.height / 2
        Katilan2.layer.masksToBounds = true
        
        Katilan3.layer.cornerRadius = Katilan3.frame.height / 2
        Katilan3.layer.masksToBounds = true
        
        Katilan4.layer.cornerRadius = Katilan4.frame.height / 2
        Katilan4.layer.masksToBounds = true
        
        Katilan5.layer.cornerRadius = Katilan5.frame.height / 2
        Katilan5.layer.masksToBounds = true
        
        if resimler.count < 2
        {
            viewControl.isHidden = true
        }
        
        txtOyunYeri.inputView = pickerViewBiletYerleri
        
        var ilkMi = false
        
        gl_Load = true
        //imgEtkinlikResmi.sd_setImage(with: URL(string: etkinlikDetayResimLink ), completed: nil)
        
        lblFiyat.text = etkinlikDetayFiyat
        lblEtkAdi.text = etkinlikDetayAd
        lblEtkinlikBolge.text = etkinlikDetayBolge
        txtEtkinlikAciklama.text = etkinlikDetayAciklama
        
        //Resimlerin altında duran sayfalama
        pageControl.numberOfPages = resimler.count
        pageControl.currentPage = 0
        
        viewControl.layer.cornerRadius = 10
        
        if etkinlikSuresizmi == true
        {
            txtEtkinlikGun.text = "Süresiz"
            txtEtkinlikAy.text = "Etkinlik"
        }
        else
        {
            let gun = utilities.ChangeDateToDay(tarih: etkinlikDetayTarih)
            let ay = utilities.ChangeDateToMonth(tarih: etkinlikDetayTarih)
            
            txtEtkinlikGun.text = gun
            txtEtkinlikAy.text = ay
        }
        
        let databaseReference = Database.database().reference()
        let biletSayisiCL = BiletSayisiCL()
        //Tüm userlara bakılır. Bu evente ait tüm ticketlar alınır.
        _ = Database.database().reference().child("users").observe(DataEventType.value) { (dataTickets) in
            if dataTickets.exists()
            {
                let valuesUsers = dataTickets.value! as! NSDictionary
                let userIDs = valuesUsers.allKeys
                
                for userID in userIDs
                {
                    let newFriend = moreFriends()
                    let singleUserDict = valuesUsers[userID] as! NSDictionary
                    
                    if let singleUserProfile = singleUserDict["profile"] as! NSDictionary?
                    {
                        let singleUserProfileGet = singleUserProfile[userID] as! NSDictionary
                        if let userProfilImageC = singleUserProfileGet["ProfilResim"] as! String?
                        {
                            newFriend.userImage = userProfilImageC
                        }
                        else
                        {
                            newFriend.userImage = "https://i.stack.imgur.com/l60Hf.png"
                        }
                        //KullaniciAdi:
                        if let userProfilKullaniciAdi = singleUserProfileGet["KullaniciAdi"] as! String?
                        {
                            newFriend.userName = userProfilKullaniciAdi
                        }
                        else
                        {
                            newFriend.userName = "Etkinlikçi"
                        }
                        
                        
                        //userName
                        
                        newFriend.userID = userID as! String
                        
                    }
                    
                    
                    if let singleUserTicket = singleUserDict["tickets"] as! NSDictionary?
                    {
                        let singleUserTickets = singleUserTicket.allKeys
                        
                        for ticketID in singleUserTickets
                        {
                            let ticketDict = singleUserTicket[ticketID] as! NSDictionary
                            let eventID = ticketDict["EventID"] as! String
                            if eventID == self.etkinlikID
                            {
                                biletSayisiCL.alinanBiletSayisi = 1
                                biletSayisiCL.grupAdi = ticketDict["Yer"] as! String
                                
                                self.biletSayisiGroupCL.append(biletSayisiCL)
                                
                                
                                let alreadyAddFriend = moreFriendList.contains(where: { (moreFriends) -> Bool in
                                    moreFriends.userID == newFriend.userID
                                })
                                
                                if alreadyAddFriend == false
                                {
                                    moreFriendList.append(newFriend)
                                }
                                
                                
                            }
                        }
                    }
                }
            }
            
            self.hideButton(count: moreFriendList.count)
        
 
            _ = Database.database().reference().child("users").child(self.userID).child("Event").child("BiletGruplari").child(self.etkinlikID).observe(.value) { (data) in
            if data.exists()
            {
                let values = data.value! as! NSDictionary
                let placeIDs = values.allKeys
                
                for plc in placeIDs
                {
                    let eventGroup = EventGroup()
                    let idPlace = plc as! String
                    let idDict = values[idPlace] as! NSDictionary
                    
                    
                    let yerAdi = idDict["Adi"] as! String
                    let yerTutar = idDict["Tutar"] as! String
                    let yerUcretBool = idDict["Ucretsiz"] as! String
                    let biletSayisi =  idDict["BiletSayisi"] as! Int
                    
                    

                    eventGroup.Ad = yerAdi
                    eventGroup.Tutar = yerTutar
                    eventGroup.Ucretsiz = yerUcretBool
                    eventGroup.BiletSayisi = biletSayisi
                    eventGroup.SatilanBiletSayisi = 0
                    if self.biletSayisiGroupCL.count > 0
                    {
                        for eventSaledTicket in self.biletSayisiGroupCL //Satılan biletler arasında dolaş.
                        {
                            if eventSaledTicket.grupAdi == eventGroup.Ad //Eğer grup adları aynı ise
                            {
                                eventGroup.SatilanBiletSayisi = eventGroup.SatilanBiletSayisi + 1 //Bilet sayısını arttır.
                            }
                        }
                    }
                    
                    if ilkMi == false //txtBoxa ilk kaydı ata
                    {
                        ilkMi = true
                        self.txtOyunYeri.text = yerAdi //İlk başlangıçtaki alan
                        if yerUcretBool == "true"
                        {
                            self.lblSeciliFiyat.text = "Ücretsiz"
                        }
                        else
                        {
                            self.lblSeciliFiyat.text = yerTutar + " TL"
                        }
                        
                        let kalanBilet = eventGroup.BiletSayisi  - eventGroup.SatilanBiletSayisi
                        
                        if kalanBilet < 1
                        {
                            self.btnSatinAlmaSayfasiGit.isEnabled = false
                        }

                        self.lblKalanKoltukSayisi.text = String(kalanBilet)
                        self.lblKalanKoltukSayisi.textColor = UIColor.red
                        
                    }
                    
                    
                    self.eventGroups.append(eventGroup)
                    //Event Group TextBox'a bağlanacak.
                }
                
            }
            
                _ = databaseReference.child("users").child(self.userID).child("Event").child("Main").child(self.etkinlikID).observe(.value) { (data) in
                
                  let valueEvent = data.value! as! NSDictionary
                
                
                self.eventUserID = valueEvent["UserID"] as! String
                
                _ = databaseReference.child("users").child(self.eventUserID).child("profile").child(self.eventUserID).observe(.value, with: { (userData) in
                    
                    let userProfile = userData.value! as! NSDictionary
                    self.isletmemi = userProfile["Isletmemi"] as! String
                  
                    //Tek veri olduğundan adres alınır.
                    let snapShotEvent = valueEvent["Adres"] as! String //EtkinlikID'nin altında adres alınır.
                    _ = databaseReference.child("users").child(self.userID).observe(.value, with: { (addressData) in
                        if addressData.hasChild("Address") //Userların altındaki tüm adresler alınır.
                        {
                            let valueAddress = addressData.value! as! NSDictionary
                            let addressDict = valueAddress["Address"] as! NSDictionary
                            let addressKeys = addressDict.allKeys
                            
                            for addresID in addressKeys
                            {
                                let idAddres = addresID as! String
                                let addressDetayDict = addressDict[idAddres] as! NSDictionary
                                let addressAdi = addressDetayDict["Başlık"] as! String
                                
                                if addressAdi == snapShotEvent
                                {
                                    self.enlem = addressDetayDict["Enlem"] as! Double
                                    self.boylam = addressDetayDict["Boylam"] as! Double
                                }
                            }
                        }
                    })
                })
            }
        }
        }
    }
    
    @IBAction func btnPaylas(_ sender: UIButton) {
        
        let popOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shared_popup") as! SharedList
        //globale taşıyoruz.
        selectedEventName = etkinlikDetayAd
        selectedEventImage = resimler[0]
        selectedEventID = etkinlikID
        selectedEventUserId = eventUserID
        
        self.addChild(popOver)
        popOver.view.frame = self.view.frame
        self.view.addSubview(popOver.view)
        popOver.didMove(toParent: self)
    }
    
    func hideButton(count : Int)
    {
        if count == 0
        {
            Katilan1.isHidden = true
            Katilan2.isHidden = true
            Katilan3.isHidden = true
            Katilan4.isHidden = true
            Katilan5.isHidden = true
            
            lblEtkinlikKatilimciYok.isHidden = false
            btnMoreFriends.isHidden = true
        }
        else if count == 1
        {
            Katilan1.isHidden = false
            Katilan2.isHidden = true
            Katilan3.isHidden = true
            Katilan4.isHidden = true
            Katilan5.isHidden = true
            
            Katilan1.sd_setImage(with: URL(string: moreFriendList[0].userImage), for: .normal, completed: nil)
            lblEtkinlikKatilimciYok.isHidden = true
            btnMoreFriends.isHidden = true
        }
        else if count == 2
        {
            Katilan1.isHidden = false
            Katilan2.isHidden = false
            Katilan3.isHidden = true
            Katilan4.isHidden = true
            Katilan5.isHidden = true
            
            Katilan1.sd_setImage(with: URL(string: moreFriendList[0].userImage), for: .normal, completed: nil)
            Katilan2.sd_setImage(with: URL(string: moreFriendList[1].userImage), for: .normal, completed: nil)
            lblEtkinlikKatilimciYok.isHidden = true
            btnMoreFriends.isHidden = true
        }
        else if count == 3
        {
            Katilan1.isHidden = false
            Katilan2.isHidden = false
            Katilan3.isHidden = false
            Katilan4.isHidden = true
            Katilan5.isHidden = true
            
            Katilan1.sd_setImage(with: URL(string: moreFriendList[0].userImage), for: .normal, completed: nil)
            Katilan2.sd_setImage(with: URL(string: moreFriendList[1].userImage), for: .normal, completed: nil)
            Katilan3.sd_setImage(with: URL(string: moreFriendList[2].userImage), for: .normal, completed: nil)
            
            lblEtkinlikKatilimciYok.isHidden = true
            btnMoreFriends.isHidden = true
        }
        else if count == 4
        {
            Katilan1.isHidden = false
            Katilan2.isHidden = false
            Katilan3.isHidden = false
            Katilan4.isHidden = false
            Katilan5.isHidden = true
            
            Katilan1.sd_setImage(with: URL(string: moreFriendList[0].userImage), for: .normal, completed: nil)
            Katilan2.sd_setImage(with: URL(string: moreFriendList[1].userImage), for: .normal, completed: nil)
            Katilan3.sd_setImage(with: URL(string: moreFriendList[2].userImage), for: .normal, completed: nil)
            Katilan4.sd_setImage(with: URL(string: moreFriendList[3].userImage), for: .normal, completed: nil)
            
            lblEtkinlikKatilimciYok.isHidden = true
            btnMoreFriends.isHidden = true
        }
        else if count == 5
        {
            Katilan1.isHidden = false
            Katilan2.isHidden = false
            Katilan3.isHidden = false
            Katilan4.isHidden = false
            Katilan5.isHidden = false
            
            Katilan1.sd_setImage(with: URL(string: moreFriendList[0].userImage), for: .normal, completed: nil)
            Katilan2.sd_setImage(with: URL(string: moreFriendList[1].userImage), for: .normal, completed: nil)
            Katilan3.sd_setImage(with: URL(string: moreFriendList[2].userImage), for: .normal, completed: nil)
            Katilan4.sd_setImage(with: URL(string: moreFriendList[3].userImage), for: .normal, completed: nil)
            Katilan5.sd_setImage(with: URL(string: moreFriendList[4].userImage), for: .normal, completed: nil)
            lblEtkinlikKatilimciYok.isHidden = true
            btnMoreFriends.isHidden = true
        }
        else if count > 5
        {
            Katilan1.isHidden = false
            Katilan2.isHidden = false
            Katilan3.isHidden = false
            Katilan4.isHidden = false
            Katilan5.isHidden = false
            
            Katilan1.sd_setImage(with: URL(string: moreFriendList[0].userImage), for: .normal, completed: nil)
            Katilan2.sd_setImage(with: URL(string: moreFriendList[1].userImage), for: .normal, completed: nil)
            Katilan3.sd_setImage(with: URL(string: moreFriendList[2].userImage), for: .normal, completed: nil)
            Katilan4.sd_setImage(with: URL(string: moreFriendList[3].userImage), for: .normal, completed: nil)
            Katilan5.sd_setImage(with: URL(string: moreFriendList[4].userImage), for: .normal, completed: nil)
            
            let yeniKayit = String(count - 5)
            lblEtkinlikKatilimciYok.isHidden = true
            btnMoreFriends.isHidden = false
            btnMoreFriends.titleLabel?.text = yeniKayit + " arkadaş daha"
        }
        
    }
    
    
    @IBAction func yolTarifiAl(_ sender: UIButton) {
        
        animateInMaps()
        viewHarita.isHidden = false
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: Double(enlem), longitude: Double(boylam))
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        
    }
    
    @IBAction func btnMapsIptal(_ sender: UIButton) {
        
        animateOutMaps()
    }
    
    
    @IBAction func View_btnYolTarifi_Al(_ sender: UIButton) {
        
        if enlem != 0 {
            if boylam != 0
            {
                self.requestCLLocation = CLLocation(latitude: Double(enlem), longitude: Double(boylam))
            }
        }
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placeMarks, error) in
            if let placeMark = placeMarks
            {
                if placeMark.count > 0
                {
                    let newPlacemark = MKPlacemark(placemark: placeMark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = "aaaa"
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
    
    @IBAction func BiletAl(_ sender: UIButton) {
        
        animateIn()
        
        ViewFirst.isHidden = false
        ViewSecond.isHidden = true
        
    }
    
    func animateIn()
    {
        self.view.addSubview(selectChairView)
        selectChairView.center = self.view.center
        selectChairView.transform = CGAffineTransform.init(scaleX: 1.3, y:  1.3)
        selectChairView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.visualEffect.isHidden = false
            self.visualEffect.effect = self.effect
            self.selectChairView.alpha = 1
            self.selectChairView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.selectChairView.transform = CGAffineTransform.init(scaleX: 1.3, y:  1.3)
            self.selectChairView.alpha = 0
            self.visualEffect.effect = nil
            self.visualEffect.isHidden = true
        }) { (success : Bool) in
            self.selectChairView.removeFromSuperview()
        }
    }
    
    func animateInMaps()
    {
        
        self.view.addSubview(viewHarita)
        viewHarita.center = self.view.center
        viewHarita.transform = CGAffineTransform.init(scaleX: 1.3, y:  1.3)
        viewHarita.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.visualEffect.isHidden = false
            self.visualEffect.effect = self.effect
            self.viewHarita.alpha = 1
            self.viewHarita.transform = CGAffineTransform.identity
        }
    }
    
    func animateOutMaps()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewHarita.transform = CGAffineTransform.init(scaleX: 1.3, y:  1.3)
            self.viewHarita.alpha = 0
            self.visualEffect.effect = nil
            self.visualEffect.isHidden = true
        }) { (success : Bool) in
            self.viewHarita.removeFromSuperview()
        }
    }
    
    
    @IBAction func ToSecondViewClick(_ sender: UIButton) {
        
        for eventG in eventGroups
        {
            if eventG.Ad == txtOyunYeri.text
            {
                yer = eventG.Ad
                fiyat = eventG.Tutar
                ucretsizDurum = eventG.Ucretsiz
                break
            }
        }
        
        if isletmemi == "false"
        {
            //Eğer işletme değilse tüm biletler ucretsiz demektir.
            ucretsizDurum = "false"
        }
        
        //Eğer ücretsiz değilse kredi kartına yönlendir
        if ucretsizDurum == "false"
        {
            ViewFirst.isHidden = true
            ViewSecond.isHidden = false
        } //Eğer ücretsiz ise QR sayfasına yönlendir. Yalnız burada da QR kodu oluşturulması gerekecek.
        else
        {
            lv_ticketID = setTicket()
            performSegue(withIdentifier: "ps_to_qr", sender: nil)
        }
    }
    
    
    @IBAction func SatinAlClick(_ sender: UIButton) {
        
        //Satın Alma İşlemleri Burada Yapılır.
        for eventG in eventGroups
        {
            if eventG.Ad == txtOyunYeri.text
            {
                yer = eventG.Ad
                fiyat = eventG.Tutar
                break
            }
        }
        
        lv_ticketID = setTicket()
        eventGroups.removeAll()
        performSegue(withIdentifier: "ps_to_qr", sender: nil)
    }
    
    @IBAction func IptalClick(_ sender: UIButton) {
        animateOut()
    }
    
    
    
    func setTicket() -> String
    {
        //İşlem Tamamlandıktan Sonra Ticket Oluşturulur.
        
        let ticketID = NSUUID().uuidString
        let ticketDB = Database.database().reference().child("users").child(UserDetail.id).child("tickets").child(ticketID)
        
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd.MM.yyyy h:s"
        let result = formatter.string(from: date)
        
        let oyunyeri = txtOyunYeri.text as! String
        
        let ticketDictionary = ["UserID" : UserDetail.id , "Tarih" : result , "EventID" : etkinlikID, "Yer" : oyunyeri, "Fiyat" : fiyat , "EventUserID" : eventUserID ]
        
        
        ticketDB.setValue(ticketDictionary) { (error, reference) in
            if error != nil
            {
                //print(error?.localizedDescription)
            }
            else
            {
                
            }
        }
        
        return ticketID
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ps_to_qr"
        {
            let destinationQRPage = segue.destination as! QRCodeTicket
            destinationQRPage.eventUserId = self.userID
            destinationQRPage.ticketNumber = lv_ticketID
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventGroups.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventGroups[row].Ad //Buradan seçildiği zaman fiyatı labela getirsin.
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtOyunYeri.text = self.eventGroups[row].Ad
        if self.eventGroups[row].Ucretsiz == "true"
        {
            lblSeciliFiyat.text = "Ücretsiz"
        }
        else
        {
            lblSeciliFiyat.text = self.eventGroups[row].Tutar + " TL"
        }
        
        let kalanBilet = self.eventGroups[row].BiletSayisi  - self.eventGroups[row].SatilanBiletSayisi
        
        if kalanBilet < 1
        {
            btnSatinAlmaSayfasiGit.isEnabled = false
        }
        
        lblKalanKoltukSayisi.text = String(kalanBilet)
        lblKalanKoltukSayisi.textColor = UIColor.red
        
        
        self.view.endEditing(false)
    }
    
    @IBAction func btnProfile(_ sender: UIButton) {
        
        StringActiveUserID = userID
        performSegue(withIdentifier: "vw_fdetay_profil", sender: nil)
    }
    
    
    @IBAction func btnKatilanlar(_ sender: UIButton) {
        StringActiveUserID = moreFriendList[sender.tag - 1].userID
        performSegue(withIdentifier: "vw_fdetay_profil", sender: nil)
    }
    
    
    @IBAction func btnDahaKatilanlar(_ sender: UIButton) {
        //morefriendlist class listi prepare metoduyla gidiyor.
        performSegue(withIdentifier: "ps_detail_mfriends", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resimler.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellDetail", for: indexPath) as! FeedDetailCell
        
        cell.imgFeedDetail.sd_setImage(with: URL(string: resimler[indexPath.row]), completed: nil)
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.34)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
