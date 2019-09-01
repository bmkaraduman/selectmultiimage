//
//  AddTicketGroup.swift
//  FirebaseDemo
//
//  Created by macbookpro on 5.12.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD

final class BiletGrupu {
    let biletGrubuAdi: String
    let biletTutari: Float
    var satisTutari: Float
    var Ucretsiz: String
    var biletAdedi : Int
    
    init(biletGrubuAdi: String, biletTutari: Float, satisTutari: Float, ucretsiz: String, bilet_Adedi : Int) {
        self.biletGrubuAdi = biletGrubuAdi
        self.biletTutari = biletTutari
        self.satisTutari = satisTutari
        self.Ucretsiz = ucretsiz
        self.biletAdedi = bilet_Adedi
    }
}


class AddTicketGroup: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var txtBiletGrubuAdi: UITextField!
    @IBOutlet weak var txtBiletTutari: UITextField!
    @IBOutlet weak var txtSatisTutari: UITextField!
    @IBOutlet weak var txtToplamBiletSayisi: UITextField!
    
    
    @IBOutlet weak var viewBiletGrubuAdi: UIView!
    @IBOutlet weak var viewBiletSayisi: UIView!
    @IBOutlet weak var tblViewBiletGruplari: UITableView!
    
    @IBOutlet weak var lblKomisyon: UILabel!
    
    
    var chkUCretsiz : String = "false"
    //var komisyon : Int = 0
    var bilet_Gruplari = [BiletGrupu]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(bilet_Gruplari.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellTicket", for: indexPath)
        
                // Configure the cell...
                let biletler = bilet_Gruplari[indexPath.row]
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        viewBiletSayisi.layer.cornerRadius = 8
        viewBiletSayisi.layer.masksToBounds = true
        
        viewBiletGrubuAdi.layer.cornerRadius = 8
        viewBiletGrubuAdi.layer.masksToBounds = true
        
        if bilet_Gruplari.count > 0
        {
            tblViewBiletGruplari.isHidden = false
        }
        else
        {
            tblViewBiletGruplari.isHidden = true
        }
        
        self.lblKomisyon.text = String(komisyon)
        
        tblViewBiletGruplari.dataSource = self
        tblViewBiletGruplari.delegate = self
        
        //tblViewBiletGruplari.isHidden = true
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func BiletGrubusaveClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "vw_BiletGrubu_EventEkle", sender: nil)
    }
    
    @IBAction func BiletGrubuGeri(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    @available(iOS 11.0, *)
    func deleteAction(at indexPath: IndexPath)->UIContextualAction
    {
        let action = UIContextualAction(style: .destructive, title: "delete") {
            (action, view, completion) in
            self.bilet_Gruplari.remove(at: indexPath.row)
            
            self.tblViewBiletGruplari.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
            
        }
        action.backgroundColor = nil
        action.image = UIImage(named: "trashicon")
        
        return action
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vw_BiletGrubu_EventEkle"
        {
            let destinationUploadEvents = segue.destination as! UploadEvents
            destinationUploadEvents.biletGruplari = bilet_Gruplari
        }
    }
    
    @IBAction func switchClicked(_ sender: UISwitch) {
        if sender.isOn == true {
            
            txtBiletTutari.isUserInteractionEnabled = false
            txtSatisTutari.isUserInteractionEnabled = false
            
            txtBiletTutari.backgroundColor = UIColor.flatWhite()
            txtSatisTutari.backgroundColor = UIColor.flatWhite()
            
            chkUCretsiz = "true"
        }
        else
        {
            txtBiletTutari.isUserInteractionEnabled = true
            //txtSatisTutari.isUserInteractionEnabled = true
            
            txtBiletTutari.backgroundColor = UIColor.white
            txtSatisTutari.backgroundColor = UIColor.white
            
            chkUCretsiz = "false"
        }
        
    }
    
 
    @IBAction func btnEkleClick(_ sender: UIButton) {
        
        if txtBiletGrubuAdi.text == ""
        {
            SVProgressHUD.showError(withStatus: "Bilet Grubu Adı Giriniz")
        }
        else if txtBiletTutari.text == "" && chkUCretsiz == "false"
        {
            SVProgressHUD.showError(withStatus: "Bilet Tutarı Giriniz")
        }
        else if txtToplamBiletSayisi.text == ""
        {
            SVProgressHUD.showError(withStatus: "Bilet Sayısını Giriniz")
        }
        else
        {
            let biletTutari1 = Float(txtBiletTutari.text!) ?? 0
            let satisTutari1 = Float(txtBiletTutari.text!) ?? 0
            
            
            bilet_Gruplari.append(BiletGrupu(biletGrubuAdi: txtBiletGrubuAdi.text ?? "", biletTutari: biletTutari1, satisTutari: satisTutari1, ucretsiz: chkUCretsiz , bilet_Adedi: Int(txtToplamBiletSayisi.text!) ?? 0))
            
            let indexPath = IndexPath(row: bilet_Gruplari.count - 1, section: 0)
            
            tblViewBiletGruplari.isHidden = false
            tblViewBiletGruplari.tableFooterView = UIView()
            
            tblViewBiletGruplari.beginUpdates()
            tblViewBiletGruplari.insertRows(at: [indexPath], with: .automatic)
            tblViewBiletGruplari.endUpdates()
            
            txtBiletGrubuAdi.text = ""
            txtSatisTutari.text = ""
            txtBiletTutari.text = ""
            txtToplamBiletSayisi.text = ""
        }

    }
    
    @IBAction func btnGeri(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func txtBiletTutari_Changed(_ sender: UITextField) {
        
        //var biletTutari2 = txtBiletTutari.text
        //var senderText = sender.text!
        let biletTutari = Float(txtBiletTutari.text!) ?? 0
        let komisyonBelirle = Float(komisyon)
        let satisTutari = ((biletTutari * komisyonBelirle) / 100 + biletTutari )
        
        let satisTutariMetin = String(satisTutari)
        txtSatisTutari.text = satisTutariMetin
    
    }
}
