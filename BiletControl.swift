//
//  BiletControl.swift
//  FirebaseDemo
//
//  Created by macbookpro on 13.04.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class BiletControl: UIViewController, AVCaptureMetadataOutputObjectsDelegate  {

    @IBOutlet weak var lblBiletAd: UILabel!
    
    @IBOutlet weak var lblBiletTarihi: UILabel!
    
    @IBOutlet weak var checkedTicket: UILabel!
    
    @IBOutlet weak var allTicket: UILabel!
    
    @IBOutlet weak var viewOnay: UIView!
    
    
    var ticketList = [TicketControlIDCl]()
    var eventID = String()
    var kontrolSayi : Int = 0
    var biletAD = String()
    var biletTarih = String()
    
    var kontrolStringList = [String]()
    
    @IBOutlet weak var lblKontrolText: UILabel!
    @IBOutlet weak var viewCamera: UIView!
    
    var video = AVCaptureVideoPreviewLayer()
    //@IBOutlet weak var square: UIImageView!
    
    @IBOutlet weak var imgDurum: UIImageView!
    
    var kontrolString = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.video.frame.size = self.viewCamera.frame.size
    }
    
    var alreadyLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kontrolString = [String]()
        viewOnay.isHidden = true
        
        lblBiletAd.text = biletAD
        lblBiletTarihi.text = biletTarih
        let allTicketsCount = String(ticketList.count)
        allTicket.text = allTicketsCount
        
        //Camerayı Aç.
        //Creating session
        let session = AVCaptureSession()
        
        //Define capture devcie
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        }
        catch
        {
            print ("ERROR")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        //video.frame = viewCamera.layer.bounds
        self.video.frame.size = self.viewCamera.frame.size
        //self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        checkedTicket.text = "0"
        //view.layer.addSublayer(video)
        viewCamera.layer.addSublayer(video)
        
        session.startRunning()
        //Kontrol edilmişlere bak.

        let databaseReference = Database.database().reference()
        
        databaseReference.observe(.value) { (data) in
            if data.hasChild("ControlTicket")
            {
                if self.alreadyLoad == false
               {
                let value = data.value! as! NSDictionary
                let controlTicket = value["ControlTicket"] as! NSDictionary
                
                if let singleControlTicket = controlTicket[self.eventID] as! NSDictionary?
                {
                    for i in (singleControlTicket.allKeys)
                    {
                        let iString = i as! String
                        self.kontrolString.append(iString)
                    }
                    let kontrolEdilmisBiletlerString = String(self.kontrolString.count)
                    //Kontrol edilmişler en başta alınır.
                    self.kontrolSayi = self.kontrolString.count
                    self.checkedTicket.text = kontrolEdilmisBiletlerString
                }
                }
               
            }
        }
        
        
  
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects != nil && metadataObjects.count != 0
        {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if object.type == AVMetadataObject.ObjectType.qr
                {
                    let ticketNumber = object.stringValue
                    
                    alreadyLoad = true
                    
                    let ticketVarmi = kontrolStringList.contains { (tickID) -> Bool in
                        tickID == ticketNumber
                    }
                    
                    if ticketVarmi == false
                    {
                        kontrolStringList.append(ticketNumber!)
                        var dahaOnceKontrolEdildimi = false
                        for i in kontrolString
                        {
                            if i == ticketNumber
                            {
                                //Zaten kontrol edilmiş biletlere buradan bakılır.
                                lblKontrolText.text == "Zaten Kontrol Edildi"
                                imgDurum.image = UIImage(named: "doubleCheck")
                                dahaOnceKontrolEdildimi = true
                                break
                            }
                        }
                        
                        
                        if dahaOnceKontrolEdildimi == false
                        {
                            var varMi = false
                            for ticketID in ticketList
                            {
                                if ticketID.TicketID == ticketNumber
                                {
                                    //Eğer varsa
                                    //1. onay resmini koy.
                                    viewOnay.isHidden = false
                                    viewOnay.backgroundColor = UIColor.flatGreen()
                                    imgDurum.image = UIImage(named: "OKTicket")
                                    //Kontrol edilmişe koy.
                                    //
                                    let post = ["TicketID" : ticketNumber, "EventID" : eventID]
                                     Database.database().reference().child("ControlTicket").child(eventID).child(ticketNumber!).setValue(post)
                                    kontrolSayi = kontrolSayi + 1
                                    checkedTicket.text = String(kontrolSayi)
                                    
                                    varMi = true
                                    break
                                }
                            }
                            
                            if varMi == false
                            {
                                viewOnay.isHidden = false
                                viewOnay.backgroundColor = UIColor.flatRed()
                                imgDurum.image = UIImage(named: "Nok_ticket")
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    @IBAction func btnGeri(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    

}
