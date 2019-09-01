//
//  SaveMyLocation.swift
//  FirebaseDemo
//
//  Created by macbookpro on 15.09.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import MapKit
import CoreLocation
import Firebase
import SVProgressHUD

struct bolge: Decodable {
    
    let bolge: String?
    let id: Int?
    let il: String?
    let ilce: String?
    let plaka: Int?
    
    init(json: [String: Any]) {
        bolge = json["bolge"] as? String ?? ""
        id = json["id"] as? Int ?? -1
        il = json["il"] as? String ?? ""
        ilce = json["ilce"] as? String ?? ""
        plaka = json["plaka"] as? Int ?? -1
    }
}

struct Alerts {
    
    static var singleAlert = ""
    
}


class SaveMyLocation: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate,
UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UISearchBarDelegate{
    
    
    //İl-İlçe İçin JSON Okuma ve PickerView Tanımlamaları
    var courses1 = [bolge]()
    var iller = [String]()
    var ilceler = [String]()
    var pickerViewIller = UIPickerView()
    var pickerViewIlceler = UIPickerView()
    var seciliIL = String.init()
    var flagSecili = false
    @IBOutlet weak var txtAdresBasligi: UITextField!
    @IBOutlet weak var txtSehir: UITextField!
    @IBOutlet weak var txtIlce: UITextField!
    
    @IBOutlet weak var searchButtonMap: UISearchBar!
    
    
    @IBOutlet weak var mpView: MKMapView!
    var manager = CLLocationManager()
    var region1 = MKCoordinateRegion.init()
    var selectedLocation = MKPointAnnotation.init()
    
    //@IBOutlet weak var barButtonSave: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //Pickerview(İl-İlçe) ayarlamaları
        pickerViewIller.delegate = self
        pickerViewIller.dataSource = self
        
        pickerViewIlceler.delegate = self
        pickerViewIlceler.dataSource = self
        
        searchButtonMap.delegate = self
        
        txtSehir.inputView = pickerViewIller
        txtIlce.inputView = pickerViewIlceler
        
        self.hideKeyboardWhenTappedAround()
        
        do {
            let url1 = Bundle.main.url(forResource: "ililce", withExtension: "json")
            let jsonData1 = try Data(contentsOf: url1!)
            
            courses1 = try JSONDecoder().decode([bolge].self, from: jsonData1)
     
            for cource in courses1
            {
                if !iller.contains(where: { $0 == cource.il })
                {
                    iller.append(cource.il!)
                }
            }
        }
        catch let error1 {
            print("Hata", error1)
        }
        
        
        mpView.delegate = self
        manager.delegate = self
    
        // Do any additional setup after loading the view.
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 1
        mpView.addGestureRecognizer(recognizer)
        
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizer.State.began
        {
            //Dokunulan noktayı bul oluştur
            let touchedPoint = gestureRecognizer.location(in: self.mpView)
            let chosenCoordinates = self.mpView.convert(touchedPoint, toCoordinateFrom: self.mpView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = "Adres"
            annotation.subtitle = "Mekan Yeri"
            selectedLocation = annotation
            flagSecili = true
            let allAnnotations = self.mpView.annotations
            self.mpView.removeAnnotations(allAnnotations)
            self.mpView.addAnnotation(annotation)
            self.mpView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Enlem-Boylam
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //Ne kadar zoomlayacağı
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        region1 = region
        mpView.setRegion(region, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewIller
        {
            return iller.count
        }
        else
        {
            return ilceler.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //self.view.endEditing(true)
        if pickerView == pickerViewIller
        {
            return iller[row]
        }
        else
        {
            return ilceler[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewIller
        {
            seciliIL = self.iller[row]
            self.txtSehir.text = seciliIL
            
            for town in courses1//İlceler seçilen ile göre doldurulur
            {
                if town.il == seciliIL
                {
                    ilceler.append(town.ilce!)
                }
            }
        }
        else if pickerView == pickerViewIlceler
        {
            self.txtIlce.text = self.ilceler[row]
        }
        
        self.view.endEditing(false)//Seçtikten sonra klavyenin tekrar kaybolması/aktif hale gelmesini sağlar.
        //İkinci texbox'ı buradan dolduracağız.
    }
    
    
    @IBAction func btnSaveEventsAddress(_ sender: UIBarButtonItem) {
        
        if txtAdresBasligi.text == ""
        {
            SVProgressHUD.showError(withStatus: "Adres Başlığı Giriniz")
        }
        else if txtSehir.text == ""
        {
            SVProgressHUD.showError(withStatus: "Şehri Seçiniz")
        }
        else if txtIlce.text == ""
        {
            SVProgressHUD.showError(withStatus: "İlçeyi Giriniz")
        }
        else if flagSecili != true
        {
            SVProgressHUD.showError(withStatus: "Haritayı İşaretleyiniz")
        }
        else
        {
            let post = ["Enlem" : selectedLocation.coordinate.latitude, "Boylam" : selectedLocation.coordinate.longitude, "Başlık": txtAdresBasligi.text, "Sehir": txtSehir.text,"Ilce" : txtIlce.text ] as [String: Any?]
            Database.database().reference().child("users").child(UserDetail.id).child("Address").childByAutoId().setValue(post)
            
            let mesajTuru = "Başarı Mesajı"
            Alerts.singleAlert = String(mesajTuru)
            performSegue(withIdentifier: "Send_To_AddEvent", sender: nil)
        }
    }
    
    @IBAction func btnCancelSaveAddress(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mevcutKonum_Click(_ sender: UIButton) {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        //Mevcut konuma pin ekler...
        let annotation = MKPointAnnotation()
        if manager.location?.coordinate != nil
        {
            annotation.coordinate = manager.location!.coordinate
            annotation.title = "New Annotation"
            annotation.subtitle = "Favori Yerler"
            selectedLocation = annotation
            let allAnnotations = self.mpView.annotations
            self.mpView.removeAnnotations(allAnnotations)
            self.mpView.addAnnotation(annotation)
            self.mpView.selectAnnotation(annotation, animated: true)
            flagSecili = true
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //print("Searching...", searchButtonMap.text)
        manager.stopUpdatingLocation()
        searchButtonMap.resignFirstResponder()
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchButtonMap.text!) { (placemarks : [CLPlacemark]?, error) in
            if error == nil
            {
                let placemark = placemarks?.first
                let anno = MKPointAnnotation()
                anno.coordinate = (placemark?.location?.coordinate)!
                anno.title = self.searchButtonMap.text!
                
                let span = MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075)
                let region = MKCoordinateRegion(center: anno.coordinate, span:  span)
                
                
                self.mpView.setRegion(region, animated: true)
                let allAnnotations = self.mpView.annotations
                self.mpView.removeAnnotations(allAnnotations)
                
                self.mpView.addAnnotation(anno)
                
                self.mpView.addAnnotation(anno)
                self.mpView.selectAnnotation(anno, animated: true)
                self.flagSecili = true
                
            }
            else
            {
                print(error?.localizedDescription ?? "error")
            }
        }
        
 
    }
    
    
    
}

