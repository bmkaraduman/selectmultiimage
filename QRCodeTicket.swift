//
//  QRCodeTicket.swift
//  FirebaseDemo
//
//  Created by macbookpro on 28.03.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage
import MapKit

class QRCodeTicket: UIViewController {

    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblSiparisTarihi: UILabel!
    
    @IBOutlet weak var lblSiparisNumarasi: UILabel!
    
    @IBOutlet weak var lblAciklama: UITextView!
    
    @IBOutlet weak var lblFiyat: UILabel!
    
    @IBOutlet weak var imgEtkinlik: UIImageView!
    
    @IBOutlet weak var lblEtkinlikBolge: UILabel!
    
    @IBOutlet weak var lblTarih: UILabel!
    
    @IBOutlet weak var lblTarihAy: UILabel!
    
    @IBOutlet weak var lblTarihGun: UILabel!
    
    @IBOutlet weak var imgKareKod: UIImageView!
    
    @IBOutlet var view_Harita: UIView!
    
    @IBOutlet weak var mpView: MKMapView!
    
    @IBOutlet weak var lblKonum: UILabel!
    
    @IBOutlet weak var viewQR: UIView!
    
    
    var utilities = Utilities()
    
    var enlem = Double()
    var boylam = Double()
    
    var requestCLLocation = CLLocation()
    
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    var effect : UIVisualEffect!

    var eventUserId : String!
    var filter : CIFilter!
    var ticketNumber : String!
    var tarih : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effect = visualEffect.effect
        visualEffect.effect = nil
        visualEffect.isHidden = true
        
        view_Harita.layer.cornerRadius = 10
        
        viewQR.layer.cornerRadius = 10
        lblAciklama.layer.cornerRadius = 10
        //self.navigationItem.setHidesBackButton(true, animated:true);
        //navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        _ = Database.database().reference().child("users").child(UserDetail.id).child("tickets").child(ticketNumber).observe(DataEventType.value) { (data) in
            
            if data.exists()
            {
                let valueTicket = data.value! as! NSDictionary
                self.lblSiparisTarihi.text = valueTicket["Tarih"] as? String
                self.lblFiyat.text = valueTicket["Fiyat"] as? String
                let etkinlikID = valueTicket["EventID"] as! String
                
                self.imgKareKod.image = self.generateQRCode(from: self.ticketNumber)
                // Do any additional setup after loading the view.
                
                _ = Database.database().reference().child("users").child(self.eventUserId).child("Event").child("Main").child(etkinlikID).observe(.value, with: { (data) in
                    
                    if data.exists()
                    {
                        let valueEvent = data.value! as! NSDictionary
                        let IL = valueEvent["IL"] as! String
                        let Ilce = valueEvent["Ilce"] as! String
                        
                        self.lblEtkinlikBolge.text = IL + "/" + Ilce
                        self.lblAciklama.text = valueEvent["Aciklama"] as? String
                        self.imgEtkinlik.sd_setImage(with: URL(string: valueEvent["Resim1"] as! String), completed: nil)
                        self.lblSiparisNumarasi.text = self.ticketNumber
                        self.lblUserName.text = UserDetail.username
                        self.tarih = valueEvent["Tarih"] as? String
                        let etkSuresizmi = valueEvent["Suresiz"] as! String
                        if etkSuresizmi == "true"
                        {
                            self.lblTarihGun.text = "Süresiz"
                            self.lblTarihAy.text = "Etkinlik"
                        }
                        else
                        {
                            self.lblTarihAy.text = self.utilities.ChangeDateToMonth(tarih: self.tarih)
                            self.lblTarihGun.text = self.utilities.ChangeDateToDay(tarih: self.tarih)
                        }
                        //utilities.ChangeDateToMonth(tarih: anaEtkinlik.etkinlikTarihi)
                        
                        
                        _ = Database.database().reference().child("users").child(self.eventUserId).child("Event").child("Main").child(etkinlikID).observe(.value) { (data) in
                            
                            let valueEvent = data.value! as! NSDictionary
    
                                //Tek veri olduğundan adres alınır.
                                let snapShotEvent = valueEvent["Adres"] as! String //EtkinlikID'nin altında adres alınır.
                                _ = Database.database().reference().child("users").child(self.eventUserId).observe(.value, with: { (addressData) in
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
                        }
                    }
                }
                )
            }
        }
    }
    
    @IBAction func btnYolTarifi(_ sender: UIButton) {
        animateInMaps()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    
    @IBAction func btnYolTarifi_Goster(_ sender: UIButton) {
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
    
    @IBAction func btnYolTarifiIptal(_ sender: UIButton) {
        animateOutMaps()
    }
    
    func animateInMaps()
    {
        self.view.addSubview(view_Harita)
        view_Harita.center = self.view.center
        view_Harita.transform = CGAffineTransform.init(scaleX: 1.3, y:  1.3)
        view_Harita.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.visualEffect.isHidden = false
            self.visualEffect.effect = self.effect
            self.view_Harita.alpha = 1
            self.view_Harita.transform = CGAffineTransform.identity
        }
    }
    
    func animateOutMaps()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.view_Harita.transform = CGAffineTransform.init(scaleX: 1.3, y:  1.3)
            self.view_Harita.alpha = 0
            self.visualEffect.effect = nil
            self.visualEffect.isHidden = true
        }) { (success : Bool) in
            self.view_Harita.removeFromSuperview()
        }
    }
    

}
