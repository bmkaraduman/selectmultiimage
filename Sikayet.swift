//
//  Sikayet.swift
//  FirebaseDemo
//
//  Created by macbookpro on 7.07.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//Bu controller sharedfeed controllerından getirilecek/çağrılacak olan sınıftır.

import UIKit
import FirebaseDatabase

class Sikayet: UIViewController {

    
    @IBOutlet weak var vw_sikayet_mainview: UIView!
    @IBOutlet weak var btnSikayetEt: UIButton!
    @IBOutlet weak var btnUygunsuzIcerik: UIButton!
    @IBOutlet weak var btnSpam: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSikayetEt.layer.cornerRadius = 10
        btnSpam.layer.cornerRadius = 10
        btnUygunsuzIcerik.layer.cornerRadius = 10
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.ShowAnimate()
        
        btnSikayetEt.isHidden = false
        btnSpam.isHidden = true
        btnUygunsuzIcerik.isHidden = true
        
        vw_sikayet_mainview.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnSikayetEt_Click(_ sender: UIButton) {
        btnSikayetEt.isHidden = true
        btnSpam.isHidden = false
        btnUygunsuzIcerik.isHidden = false
    }
    
    
    @IBAction func btnUygunsuzIcerik(_ sender: UIButton) {
        
        saveData(sikayetTuru: "Spam")
    }
    
    
    @IBAction func btnSpam_Click(_ sender: UIButton) {
        
        saveData(sikayetTuru: "Spam")
        
    }
    
    func saveData(sikayetTuru : String)
    {
        let databaseReference = Database.database().reference()
        
        let postSikayet = ["SikayetEdenID" : UserDetail.id, "SikayetEdilen" : selectedEventUserId, "SikayetIcerik" : selectedEventID, "Tur" : sikayetTuru] as [String : Any]
        
        databaseReference.child("Sikayet").childByAutoId().setValue(postSikayet) { (error, ref) in
            if error != nil
            {
                
            }
            else
            {
                self.removeAnimate()
            }
        }
        
    }
    
    
    @IBAction func btnIptal_Click(_ sender: UIButton) {
        self.removeAnimate()
    }
    
    func ShowAnimate()
    {
        self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }
        
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }) { (finished) in
            if finished == true
            {
                self.view.removeFromSuperview()
            }
        }
    }
    

}
