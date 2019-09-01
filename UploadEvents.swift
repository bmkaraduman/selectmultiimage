//
//  UploadEvents.swift
//  FirebaseDemo
//
//  Created by macbookpro on 31.07.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Photos
import SVProgressHUD
import YPImagePicker

struct Etkinlik {
      static  var etkinlikAdi = ""
      static  var etkinlikTarihi = ""
      static  var EtkinlikSaati = ""
      static  var etkinlikAciklama = ""
      static  var etkinlikSuresiz = false
      static  var etkinlikAdresi = ""
      static  var etkinlikUcretsiz = false
      static  var etkinlikKategorisi = ""
}

final class KonumBilgileri {
    var KonumGRAd : String
    let Ilce: String
    let Sehir: String
    
    
    init(ilce: String, sehir: String, konumGrAd: String) {
        self.Ilce = ilce
        self.Sehir = sehir
        self.KonumGRAd = konumGrAd
    }
}


var yeniSayfa = false
var PhotoArray = [UIImage]()
var komisyon = 0

class UploadEvents: SideBarController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
 UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtEtkinlikAdi: UITextField!
    @IBOutlet weak var txtEtkinlikTarihi: UITextField!
    @IBOutlet weak var txtEtkinlikSaati: UITextField!
    //@IBOutlet weak var txtAciklama: UITextField!
    
    @IBOutlet weak var txtAciklama: UITextView!
    @IBOutlet weak var ddlEtkinlikAdresi: UITextField!
    @IBOutlet weak var ddlBiletKategorisi: UITextField!
    
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!
    @IBOutlet weak var imgView4: UIImageView!
    
    var pickerViewAdresler = UIPickerView()
    var pickerViewKategoriler = UIPickerView()
    //var pickerViewAciklama = UIPickerView()
    
    var datePicker = UIDatePicker()
    var timePicker = UIDatePicker()
    
    var flag = 0
    //var addressData = [String]()
    var catData = [String]()
    var biletGruplari = [BiletGrupu]()
    var konumBilgileri = [KonumBilgileri]()
    var uuid = NSUUID().uuidString
    
    var aciklamaList = ["1","2","3","4"]
    
    var chk_Ucretsiz : Bool = false
    var chk_Suresiz : Bool = false
    
    //Çoklu Resim Seçme
    var SelectedAssets = [PHAsset]()

    @IBOutlet weak var tableView2: UITableView!
    
    @IBOutlet weak var vw_etkinlik_anametinler: UIView!
    
    @IBOutlet weak var vw_etkinlik_resim: UIView!
    
    @IBOutlet weak var vw_etkinlik_adresi: UIView!
    
    @IBOutlet weak var img_upload_orta: UIImageView!
    @IBOutlet weak var img_upload_alt: UIImageView!
    @IBOutlet weak var img_upload_ust: UIImageView!
    
    @IBOutlet weak var viewEtkinlikAdi: UIView!
    
    @IBOutlet weak var viewEtkinlikAciklama: UIView!
    
    @IBOutlet weak var viewEtkinlikKategorisi: UIView!
    
    //Yeni resim kütüphanesi için
    var selectedItems = [YPMediaItem]()
    let selectedImageV = UIImageView()
    
    let date = Date()
    let formatter = DateFormatter()
    var result = String()
    
    @IBOutlet weak var deleteBar: UIBarButtonItem!
    
    @IBOutlet weak var nvBar: UINavigationBar!
    @IBOutlet weak var navBarItems: UINavigationItem!
    
    @IBOutlet weak var btnEtkinlikSil: UIButton!
    
    //Eğer güncelleme maksadıyla geliniyorsa, aşağıdaki tanımlamalar kullanılacak.
    var eventID = ""
    var ticketVarmi = false
    @IBOutlet weak var switch_Suresiz: UISwitch!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        if biletGruplari.count > 0
        {
            tableView2.isHidden = false
        }
        else
        {
            tableView2.isHidden = true
        }
        
        btnEtkinlikSil.layer.cornerRadius = 10
        
        tableView2.dataSource = self
        tableView2.delegate = self
        
        //Başka ekranlara geçiş yaparken hafızaya atıyoruz.
        if Etkinlik() != nil
        {
            txtEtkinlikAdi.text = Etkinlik.etkinlikAdi
            txtEtkinlikTarihi.text = Etkinlik.etkinlikTarihi
            txtEtkinlikSaati.text = Etkinlik.EtkinlikSaati
            txtAciklama.text = Etkinlik.etkinlikAciklama
            ddlEtkinlikAdresi.text = Etkinlik.etkinlikAdresi
            ddlBiletKategorisi.text = Etkinlik.etkinlikKategorisi
        }
        
        formatter.dateFormat = "dd.MM.yyyy"
        result = formatter.string(from: date)
        getAddressFromDB()
        getCategoriesFromDB()
        
        pickerViewAdresler.delegate = self
        pickerViewAdresler.dataSource = self
        pickerViewKategoriler.delegate = self
        pickerViewKategoriler.dataSource = self
        
        //Dolu Boş Kontrolü Koy Şunlara
        //txtAciklama.inputView =  pickerViewAciklama
        ddlBiletKategorisi.inputView = pickerViewKategoriler
        ddlEtkinlikAdresi.inputView = pickerViewAdresler
        
        //Tarih Listelendi
        showDatePicker()
        showTimePicker()
        
        //Viewları round yap
        vw_etkinlik_resim.layer.cornerRadius = 8
        vw_etkinlik_adresi.layer.cornerRadius = 8
        vw_etkinlik_anametinler.layer.cornerRadius = 8
        viewEtkinlikAdi.layer.cornerRadius = 8
        viewEtkinlikAciklama.layer.cornerRadius = 8
        viewEtkinlikKategorisi.layer.cornerRadius = 8
        
        viewEtkinlikAdi.layer.masksToBounds = true
        viewEtkinlikAciklama.layer.masksToBounds = true
        viewEtkinlikKategorisi.layer.masksToBounds = true
        vw_etkinlik_resim.layer.masksToBounds = true
        vw_etkinlik_anametinler.layer.masksToBounds = true
        vw_etkinlik_adresi.layer.masksToBounds = true
        
        
        //Eğer yeni etkinlik girilecekse önceki etkinlik boşaltılacak.
        if yeniSayfa == true
        {
            txtAciklama.text = ""
            txtEtkinlikAdi.text = ""
            txtEtkinlikSaati.text = ""
            txtEtkinlikTarihi.text = ""
            imgView1.image = nil
            imgView2.image = nil
            imgView3.image = nil
            imgView4.image = nil
            eventID = ""
            yeniSayfa = false
            PhotoArray.removeAll()
            biletGruplari.removeAll()
            tableView2.reloadData()
            self.tableView2.isHidden = true
        }
        
        
        let photoArrayCount = PhotoArray.count
        
        if photoArrayCount == 1 {
            imgView1.image = PhotoArray[0]
            imgView1.tag = 2
            imgView2.tag = 1
            imgView3.tag = 1
            imgView4.tag = 1
        }
        else if photoArrayCount == 2 {
            imgView1.image = PhotoArray[0]
            imgView2.image = PhotoArray[1]
            imgView1.tag = 2
            imgView2.tag = 2
            imgView3.tag = 1
            imgView4.tag = 1
        }
        else if photoArrayCount == 3
        {
            imgView1.image = PhotoArray[0]
            imgView2.image = PhotoArray[1]
            imgView3.image = PhotoArray[2]
            
            imgView1.tag = 2
            imgView2.tag = 2
            imgView3.tag = 2
            imgView4.tag = 1
        }
        else if photoArrayCount == 4
        {
            imgView1.image = PhotoArray[0]
            imgView2.image = PhotoArray[1]
            imgView3.image = PhotoArray[2]
            imgView4.image = PhotoArray[3]
            
            imgView1.tag = 2
            imgView2.tag = 2
            imgView3.tag = 2
            imgView4.tag = 2
        }
        else
        {
            imgView1.tag = 1
            imgView2.tag = 1
            imgView3.tag = 1
            imgView4.tag = 1
        }
        
        Database.database().reference().child("Komisyon").observe(DataEventType.value, with:
            {
                (snapshot) in
                //let values = snapshot.value! as! NSDictionary
                let values = snapshot.value! as! [String: Any]
                
                let deger = values["Name"] as! String
                //self.lblKomisyon.text = "% " + deger
                komisyon = Int(deger)!
        }
        )
        //Burada Eğer klavye açıksa, harici tıklama da klavye kapatılır.
        self.hideKeyboardWhenTappedAround()
        if eventID != ""
        {
            btnEtkinlikSil.isHidden = false
            _ = Database.database().reference().child("users").child(UserDetail.id).child("Event").child("Main").child(eventID).observe(.value, with: { (data) in
                if data.exists()
                {
                    let valueEvent = data.value! as! NSDictionary
                    
                    
                    self.txtEtkinlikAdi.text = (valueEvent["Adi"] as! String)
                    self.txtEtkinlikTarihi.text = (valueEvent["Tarih"] as! String)
                    self.txtEtkinlikSaati.text = (valueEvent["Saat"] as! String)
                    self.txtAciklama.text = (valueEvent["Aciklama"] as! String)
                    self.ddlEtkinlikAdresi.text = (valueEvent["Adres"] as! String)
                    let etResmi = valueEvent["Resim1"] as? String
                    let etResmi2 = valueEvent["Resim2"] as? String
                    let etResmi3 = valueEvent["Resim3"] as? String
                    let etResmi4 = valueEvent["Resim4"] as? String
                    
                    if etResmi != ""
                    {
                        self.imgView1.sd_setImage(with: URL(string: etResmi!), completed: { (image, error, ss, url) in
                            if error == nil
                            {
                                self.imgView1.tag = 2
                                PhotoArray.append(image!)
                            }
                        })
                        
                    }
                    if etResmi2 != ""
                    {
                        self.imgView2.sd_setImage(with: URL(string: etResmi2!), completed: { (image, error, ss, url) in
                            if error == nil
                            {
                                self.imgView2.tag = 2
                                PhotoArray.append(image!)
                            }
                        })
                    }
                    if etResmi3 != ""
                    {
                        self.imgView3.sd_setImage(with: URL(string: etResmi3!), completed: { (image, error, ss, url) in
                            if error == nil
                            {
                                self.imgView3.tag = 2
                                PhotoArray.append(image!)
                            }
                        })
                    }
                    if etResmi4 != ""
                    {
                        self.imgView4.sd_setImage(with: URL(string: etResmi4!), completed: { (image, error, ss, url) in
                            if error == nil
                            {
                                self.imgView4.tag = 2
                                PhotoArray.append(image!)
                            }
                        })
                    }
                    
                    let etkSuresizmi = valueEvent["Suresiz"] as! String
                    
                    if etkSuresizmi == "true"
                    {
                        self.switch_Suresiz.isOn = true
                    }
                    else
                    {
                        self.switch_Suresiz.isOn = false
                    }
                    
                    self.ddlBiletKategorisi.text = valueEvent["Kategori"] as! String
                    //Bilet Fiyatları Gösterilir.
                    _ = Database.database().reference().child("users").child(UserDetail.id).child("Event").child("BiletGruplari").child(self.eventID).observe(.value) { (data) in
                        if data.exists()
                        {
                            let values = data.value! as! NSDictionary
                            let placeIDs = values.allKeys
                            
                            for plc in placeIDs
                            {
                    
                                let idPlace = plc as! String
                                let idDict = values[idPlace] as! NSDictionary
                                
                                let yerAdi = idDict["Adi"] as! String
                                let yerTutar = idDict["Tutar"] as! String
                                var yerTutar2 = Float(yerTutar)
                                let yerUcretBool = idDict["Ucretsiz"] as! String
                                
                                if yerUcretBool == "true"
                                {
                                    yerTutar2 = 0.0
                                }
                                
                                let biletSayisi =  idDict["BiletSayisi"] as! Int
                                self.biletGruplari.append(BiletGrupu(biletGrubuAdi: yerAdi, biletTutari: yerTutar2!, satisTutari: yerTutar2!, ucretsiz: yerUcretBool, bilet_Adedi: biletSayisi))
                                
                            }
                            if self.biletGruplari.count > 0
                            {
                                self.tableView2.isHidden = false
                            }
                            else
                            {
                                self.tableView2.isHidden = true
                            }
                            self.tableView2.reloadData()
                        }}
                    //Bilet Gruplari Sonu
                }
            }) { (error) in
                if error != nil
                {
                    
                }
            }
        }
        else
        {
            btnEtkinlikSil.isHidden = true
        }
        
    }
    @IBAction func deleteEtkinlik(_ sender: UIButton) {
        if ticketVarmi == true
        {
            SVProgressHUD.showError(withStatus: "Bu etkinliğe ait bilet satın alınmıştır, silinemez")
        }
        else
        {
            let databaseReference = Database.database().reference()
            
            //Ticket var mı bakılır.
            _ = databaseReference.child("users").child(UserDetail.id).child("Event").child("Main").child(eventID).removeValue(completionBlock: { (error, ref) in
                SVProgressHUD.showSuccess(withStatus: "Başarılı bir şekilde silinmiştir")
                
                self.txtAciklama.text = ""
                self.txtEtkinlikAdi.text = ""
                self.txtEtkinlikSaati.text = ""
                self.txtEtkinlikTarihi.text = ""
                self.imgView1.image = nil
                self.imgView2.image = nil
                self.imgView3.image = nil
                self.imgView4.image = nil
                self.eventID = ""
                yeniSayfa = false
                PhotoArray.removeAll()
                self.biletGruplari.removeAll()
                self.tableView2.reloadData()
                self.tableView2.isHidden = true
                
            })
        }
        
    }
    
    
    
    
    func showDatePicker()
    {
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtEtkinlikTarihi.inputAccessoryView = toolbar
        txtEtkinlikTarihi.inputView = datePicker
    }
    
    func showTimePicker()
    {
        timePicker.datePickerMode = .time
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTimePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtEtkinlikSaati.inputAccessoryView = toolbar
        txtEtkinlikSaati.inputView = timePicker
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        txtEtkinlikTarihi.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func doneTimePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" //formatter.dateFormat = "dd/MM/yyyy"
        txtEtkinlikSaati.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    func getAddressFromDB()
    {
        let userID = UserDetail.id//Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").child(userID).child("Address").observe(DataEventType.value, with: { (snapshot) in
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if snapshot.exists()
            {
                let values = snapshot.value! as! NSDictionary
                let postIDs = values.allKeys
                for id in postIDs
                {
                let singlePost = values[id] as! NSDictionary
                //self.addressData.append(singlePost["Başlık"] as! String)
                self.konumBilgileri.append(KonumBilgileri.init(ilce: singlePost["Ilce"] as! String, sehir: singlePost["Sehir"] as! String, konumGrAd: singlePost["Başlık"] as! String))
                
                }
            }
        })
    }
    
    func getCategoriesFromDB()
    {
        Database.database().reference().child("Categories").observe(DataEventType.value, with:
            {
                (snapshot) in
                    //let values = snapshot.value! as! NSDictionary
                    let values = snapshot.value! as! NSDictionary
                    let catIDs = values.allKeys
                
                for id in catIDs
                {
                    let singleCat = values[id] as! NSDictionary
                    self.catData.append(singleCat["Name"] as! String)
                }
        }
      )
    }
    
    //Süresiz switch
    @IBAction func chkSuresiz(_ sender: UISwitch) {
        
        //Eğer süresiz olarak belirtilirse, tarih ve saat değişecek...Ayrıca view boyutu küçülecek.
        if sender.isOn == true  {
            txtEtkinlikTarihi.isUserInteractionEnabled = false
            txtEtkinlikSaati.isUserInteractionEnabled = false
            
            txtEtkinlikTarihi.backgroundColor = UIColor.flatWhite()
            txtEtkinlikSaati.backgroundColor = UIColor.flatWhite()
            
            Etkinlik.etkinlikSuresiz = true
            
            
            chk_Suresiz = true
        }
        else
        {
            txtEtkinlikTarihi.isUserInteractionEnabled = true
            txtEtkinlikSaati.isUserInteractionEnabled = true
            
            txtEtkinlikTarihi.backgroundColor = UIColor.white
            txtEtkinlikSaati.backgroundColor = UIColor.white
            
            Etkinlik.etkinlikSuresiz = false
            
            chk_Suresiz = false
        }
    }
   
    func EtkinlikYedekle()
    {
        Etkinlik.etkinlikAdi = txtEtkinlikAdi.text ?? ""
        Etkinlik.etkinlikTarihi = txtEtkinlikTarihi.text ?? ""
        Etkinlik.EtkinlikSaati = txtEtkinlikSaati.text ?? ""
        Etkinlik.etkinlikAciklama = txtAciklama.text ?? ""
        Etkinlik.etkinlikAdresi = ddlEtkinlikAdresi.text ?? ""
        Etkinlik.etkinlikKategorisi = ddlBiletKategorisi.text ?? ""
    }
    
    
    @IBAction func btnNewAddress(_ sender: UIButton) {
        EtkinlikYedekle()
        performSegue(withIdentifier: "send_to_newaddress", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(biletGruplari.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        let biletler = biletGruplari[indexPath.row]
        var satisTutariBilet = String(biletler.satisTutari)
        if satisTutariBilet == "0.0"
        {
           satisTutariBilet = "Ücretsiz"
        }
        let toplamBiletSayisi = String(biletler.biletAdedi)
        cell.textLabel?.text = biletler.biletGrubuAdi + " - Bilet Tutari: " + satisTutariBilet + " - Bilet Sayısı: " + toplamBiletSayisi
        
        cell.backgroundColor = UIColor.flatSkyBlue()
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 5
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == pickerViewAdresler
        {
            return konumBilgileri.count
        }
        else
        {
            return catData.count
        }

        
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == pickerViewAdresler
        {
            return konumBilgileri[row].KonumGRAd
        }
        else
        {
            return catData[row]
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewAdresler
        {
            self.ddlEtkinlikAdresi.text = self.konumBilgileri[row].KonumGRAd
        }
        else
        {
            self.ddlBiletKategorisi.text = self.catData[row]
        }
       
        self.view.endEditing(false)
    }
    
    @IBAction func barBtnEtkinlikKaydet(_ sender: UIBarButtonItem) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child("ActivityImages")
        
        let img1_path = NSUUID().uuidString + ".jpg"
        let img2_path = NSUUID().uuidString + ".jpg"
        let img3_path = NSUUID().uuidString + ".jpg"
        let img4_path = NSUUID().uuidString + ".jpg"

        let mediaImageRef1  = mediaFolder.child(img1_path)
        let mediaImageRef2  = mediaFolder.child(img2_path)
        let mediaImageRef3  = mediaFolder.child(img3_path)
        let mediaImageRef4  = mediaFolder.child(img4_path)
        
        var resim1 = ""
        var resim2 = ""
        var resim3 = ""
        var resim4 = ""

        
        let etkTarihi = formatter.date(from: self.txtEtkinlikTarihi.text!)
        if etkTarihi! < date && chk_Suresiz == false
        {
            SVProgressHUD.showError(withStatus: "Etkinlik Tarihi İleri Bir Tarih Olmalıdır")
        }
        else if imgView1.tag != 2
        {
            SVProgressHUD.showError(withStatus: "Lütfen En Az 1 Tane Etkinlik Resmi Giriniz")
        }
        else if txtEtkinlikAdi.text == ""
        {
            SVProgressHUD.showError(withStatus: "Lütfen Etkinlik Adını Giriniz")
        }
        else if txtAciklama.text == ""
        {
            SVProgressHUD.showError(withStatus: "Lütfen Etkinlik Açıklaması Giriniz")
        }
        else if ddlEtkinlikAdresi.text == ""
        {
            SVProgressHUD.showError(withStatus: "Lütfen Etkinlik Adresini Giriniz")
        }
        else if biletGruplari.count == 0
        {
            SVProgressHUD.showError(withStatus: "Lütfen Bilet Fiyatını Belirleyiniz")
        }
        else
        {
            SVProgressHUD.show(withStatus: "Etkinliğiniz kaydediliyor...")
            
            if  imgView1.tag == 2
            {
                //Aşağıdaki kodu şundan dolayı yazdı...downloadURL async çalışan bir method, o yüzden kaydetme işlemini yapmadan önce downloadURl işleminin tamamlanması gerekiyor. 4 resim olduğu için de 4 resminde URL'i alındıktan sonra kaydetme işlemi yapılmaktadır.
                if let img1 = imgView1.image?.jpegData(compressionQuality: 0.1)
                {
                    mediaImageRef1.putData(img1).observe(StorageTaskStatus.success) { (snapShot) in
                        snapShot.reference.downloadURL(completion: { (url, error) in
                            resim1 = (url?.absoluteString)!
                            //2. Resim Yüklenir.
                            if self.imgView2.tag == 2
                            {
                                if  let img2 = self.imgView2.image?.jpegData(compressionQuality: 0.1)
                                {
                                    mediaImageRef2.putData(img2).observe(StorageTaskStatus.success) { (snapShot) in
                                        snapShot.reference.downloadURL(completion: { (url, error) in
                                            resim2 = (url?.absoluteString)!
                                            //3. Resim Yüklenir.
                                            if self.imgView3.tag == 2
                                            {
                                                if  let img3 = self.imgView3.image?.jpegData(compressionQuality: 0.1)
                                                {                                                    mediaImageRef3.putData(img3).observe(StorageTaskStatus.success) { (snapShot) in
                                                        snapShot.reference.downloadURL(completion: { (url, error) in
                                                            resim3 = (url?.absoluteString)!
                                                            //4. Resim Eklenir.
                                                            if  self.imgView4.tag == 2
                                                            {
                                                                if  let img4 = self.imgView4.image?.jpegData(compressionQuality: 0.1)
                                                                {
                                                                    mediaImageRef4.putData(img4).observe(StorageTaskStatus.success) { (snapShot) in
                                                                        snapShot.reference.downloadURL(completion: { (url, error) in
                                                                            resim4 = (url?.absoluteString)!
                                                                                self.UploadData(pic1: resim1, pic2: resim2, pic3: resim3, pic4: resim4)
                                                                        })
                                                                    }
                                                                }
                                                            }
                                                            else
                                                            {
                                                                self.UploadData(pic1: resim1, pic2: resim2, pic3: resim3, pic4: resim4)
                                                            }
                                                        })
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                self.UploadData(pic1: resim1, pic2: resim2, pic3: resim3, pic4: resim4)
                                            }
                                        })
                                    }
                                }
                                else
                                {
                                    self.UploadData(pic1: resim1, pic2: resim2, pic3: resim3, pic4: resim4)
                                }
                            }
                            else
                            {
                                self.UploadData(pic1: resim1, pic2: resim2, pic3: resim3, pic4: resim4)
                            }
                        })
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vw_event_biletgrubuekle"
        {
            let destinationAddTicketGroup = segue.destination as! AddTicketGroup
            destinationAddTicketGroup.bilet_Gruplari = biletGruplari
        }
    }
    
    @IBAction func btnEtkinlikResmiYukle(_ sender: UIButton) {

        
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo //Sadece resimleri istiyorum.
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = .library
        config.screens = [.library]
        config.showsCrop = .rectangle(ratio: (16/9))
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        //config.hide = false
        config.library.maxNumberOfItems = 4
        let picker = YPImagePicker(configuration: config)
        
        /* Multiple media implementation */
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.selectedImageV.image = photo.image
                    picker.dismiss(animated: true, completion: nil)
                case .video(let video):
                    print("İleride video için eklenebilir")
//                    self.selectedImageV.image = video.thumbnail
//
//                    let assetURL = video.url
//                    let playerVC = AVPlayerViewController()
//                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
//                    playerVC.player = player
                    
//                    picker.dismiss(animated: true, completion: { [weak self] in
//                        self?.present(playerVC, animated: true, completion: nil)
//                        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
//                    })
                }
            }
            var sayac = 0
            for resimSec in items
            {
                sayac = sayac + 1
                if items.count == 4
                {
                    switch resimSec
                    {
                    case .photo(let resim) :
                        if sayac == 1 { self.imgView1.image = resim.image
                            self.imgView1.tag = 2
                        }
                        if sayac == 2 { self.imgView2.image = resim.image
                            self.imgView2.tag = 2
                        }
                        if sayac == 3 { self.imgView3.image = resim.image
                            self.imgView3.tag = 2
                        }
                        if sayac == 4 { self.imgView4.image = resim.image
                            self.imgView4.tag = 2
                        }
                        PhotoArray.append(resim.image)
                        
                    case .video(let vidyo) :
                        print("Yaz Bakalım")
                    }
                }
                if items.count == 3
                {
                    switch resimSec
                    {
                    case .photo(let resim) :
                        if sayac == 1 {
                            self.imgView1.image = resim.image
                            self.imgView1.tag = 2
                        }
                        if sayac == 2 {
                            self.imgView2.image = resim.image
                            self.imgView2.tag = 2
                        }
                        if sayac == 3 {
                            self.imgView3.image = resim.image
                            self.imgView3.tag = 2
                        }
                        PhotoArray.append(resim.image)
                    case .video(let vidyo) :
                        print("Yaz Bakalım")
                    }
                }
                if items.count == 2
                {
                    switch resimSec
                    {
                    case .photo(let resim) :
                        if sayac == 1 {
                            self.imgView1.image = resim.image
                            self.imgView1.tag = 2
                        }
                        if sayac == 2 {
                            self.imgView2.image = resim.image
                            self.imgView2.tag = 2
                        }
                        PhotoArray.append(resim.image)
                    case .video(let vidyo) :
                        print("Yaz Bakalım")
                    }
                }
                if items.count == 1
                {
                    switch resimSec
                    {
                    case .photo(let resim) :
                        if sayac == 1 {
                            self.imgView1.image = resim.image
                            self.imgView1.tag = 2}
                        PhotoArray.append(resim.image)
                    case .video(let vidyo) :
                        print("Yaz Bakalım")
                    }
                }
                if items.count == 0
                {
                    
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    
    @objc
    func showResults() {
        if selectedItems.count > 0 {
            let gallery = YPSelectionsGalleryVC(items: selectedItems) { g, _ in
                g.dismiss(animated: true, completion: nil)
            }
            let navC = UINavigationController(rootViewController: gallery)
            self.present(navC, animated: true, completion: nil)
        } else {
            print("No items selected yet.")
        }
    }
    
    @IBAction func BiletGrupFiyatlariBelirle(_ sender: UIButton) {
        EtkinlikYedekle()
        performSegue(withIdentifier: "vw_event_biletgrubuekle", sender: nil)
    }
    
    func UploadData(pic1 : String, pic2 : String, pic3 : String, pic4 : String) {
        
        var EventUId = ""
        //Eğer güncelleme olacaksa;
        if eventID != ""
        {
            EventUId = eventID
        }
        else //Yeni kayıt ise
        {
            EventUId = NSUUID().uuidString
        }
        
        let ref = Database.database().reference().child("users").child(UserDetail.id).child("Event").child("Main").child(EventUId)
        
        let key = ref.key

        
        var biletGrubuAdi = String()
        var biletFiyati = String()
        
        var enUcuzBilet = Float()
        enUcuzBilet = 999.99
        var flag = false
        
        //Bilet gruplarını kaydettiğimiz yer burası...
    Database.database().reference().child("users").child(UserDetail.id).child("Event").child("BiletGruplari").child(key).removeValue()
        
        
        for blGrubu in self.biletGruplari
        {
            if blGrubu.Ucretsiz == "false"
            {
                if blGrubu.satisTutari < enUcuzBilet
                {
                    enUcuzBilet = blGrubu.satisTutari
                    flag = true
                    //Eğer herhangi bir şekilde ücret tanımlanmışsa, biletgruplarından biri ücretsiz olsa bile ücretli olanlardan birisini göster.
                }
            }
            else if flag == false && blGrubu.Ucretsiz == "true"
            {
                self.chk_Ucretsiz = true
            }
            
            biletGrubuAdi = blGrubu.biletGrubuAdi
            biletFiyati = String(blGrubu.biletTutari)
            Database.database().reference().child("users").child(UserDetail.id).child("Event").child("BiletGruplari").child(key).childByAutoId().setValue(["Adi" : biletGrubuAdi, "Tutar" : biletFiyati, "Ucretsiz" : blGrubu.Ucretsiz , "BiletSayisi" : blGrubu.biletAdedi])
        }
        
        var scIL = String()
        var scIlce = String()

        if let i = konumBilgileri.firstIndex(where: { $0.KonumGRAd == ddlEtkinlikAdresi.text as! String })
        {
            scIL = konumBilgileri[i].Sehir
            scIlce = konumBilgileri[i].Ilce
        }
        
        var enUcuzBiletString = String()
        enUcuzBiletString = String(enUcuzBilet)
        
        let userID = UserDetail.id //Auth.auth().currentUser?.uid
        
        
        ref.setValue(["Adi" : self.txtEtkinlikAdi.text!, "Suresiz" : String(self.chk_Suresiz), "Tarih" : self.txtEtkinlikTarihi.text ?? "19.05.2099", "Saat" : self.txtEtkinlikSaati.text ?? "22:00", "Aciklama" : self.txtAciklama.text!, "Adres" : self.ddlEtkinlikAdresi.text!,"IL" : scIL, "Ilce" : scIlce, "Ucretsiz" : self.chk_Ucretsiz, "Kategori" : self.ddlBiletKategorisi.text!, "OlusturulmaTarihi" : result, "Resim1" : pic1 , "Resim2" : pic2 , "Resim3" : pic3 , "Resim4" : pic4, "EnUcuz" : enUcuzBiletString , "UserID" : userID]) { (error, ref) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            else
            {            Database.database().reference().child("users").child(UserDetail.id).child("Shared").child(EventUId).setValue(["eventID" : EventUId, "userID" : userID], withCompletionBlock: { (error2, ref2) in
                    if error2 != nil
                    {
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    else
                    {
                        SVProgressHUD.dismiss()
                        //0'lama
                        self.txtAciklama.text = ""
                        self.txtEtkinlikSaati.text = ""
                        self.txtEtkinlikTarihi.text = ""
                        self.txtEtkinlikAdi.text = ""
                        PhotoArray.removeAll()
                        self.ddlBiletKategorisi.text = ""
                        self.ddlEtkinlikAdresi.text = ""
                        
                        SVProgressHUD.showSuccess(withStatus: "Başarılı olarak kaydedildi")
                        
                        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func btnGeri(_ sender: UIBarButtonItem) {
        
        //self.dismiss çalışmaz, çünkü geldiği yer sidebar
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
}
