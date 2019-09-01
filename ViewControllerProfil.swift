//
//  ViewControllerDeneme.swift
//  FirebaseDemo
//
//  Created by macbookpro on 30.12.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import GoogleSignIn
import SDWebImage
import FirebaseDatabase
import SVProgressHUD
import Photos
import SVProgressHUD
import CoreData


class ViewControllerProfil: SideBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var lblDeneme: UILabel!
    @IBOutlet weak var txtAdSoyad: UITextField!
    
    @IBOutlet weak var txtKullaniciAdi: UITextField!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var btnProfilResimDegistir: UIButton!
    
    @IBOutlet weak var lblGozukecekAd: UILabel!
    
    @IBOutlet weak var txtGozukecekFirmaAdi: UITextField!
    
    @IBOutlet weak var txtMotto: UITextField!
    
    @IBOutlet weak var switchGizli: UISwitch!
    
    @IBOutlet weak var switchIsletmeC: UISwitch!
    
    
    
    var switchIsletme : Bool = false
    var switchGizliHesap : String = "false"
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2
        imgProfile.layer.masksToBounds = true
        imgProfile.contentMode = .scaleAspectFill
        imgProfile.layer.masksToBounds = true
        
        if switchIsletmeC.isOn == true
        {
            //İşletme sahibi hesabı default olarak kapalı gelecek
            lblGozukecekAd.isHidden = false
            txtGozukecekFirmaAdi.isHidden = false
            switchIsletme = true
        }
        else
        {
            //İşletme sahibi hesabı default olarak kapalı gelecek
            lblGozukecekAd.isHidden = true
            txtGozukecekFirmaAdi.isHidden = true
            switchIsletme = false
        }
        
        txtGozukecekFirmaAdi.isHidden = true
        self.hideKeyboardWhenTappedAround()
       
       lblDeneme.text = UserDetail.email
        //(getUser, hata) = getDBClass.getUserDetail(userID: UserDetail.id, ref: dataRef)
        if UserDetail.kullaniciVarmi == "var" //Eğer kullanıcı var ise
        {
            txtKullaniciAdi.text = UserDetail.username
            txtMotto.text = UserDetail.motto
            txtAdSoyad.text = UserDetail.adsoayd
            
            if UserDetail.isletmeSahibimi == "true"
            {
                txtGozukecekFirmaAdi.isHidden = false
                lblGozukecekAd.isHidden = false
                txtGozukecekFirmaAdi.text = UserDetail.isletmeGozukecekAd
                switchIsletmeC.isOn = true
                switchIsletme = true
            }
            else
            {
                txtGozukecekFirmaAdi.isHidden = true
                lblGozukecekAd.isHidden = true
                switchIsletmeC.isOn = false
                switchIsletme = false
            }
            
            if UserDetail.gizliHesap == "true"
            {
                switchGizli.isOn = true
            }
            //cell.imgProfilImage.sd_setImage(with: URL(string: UserDetail.profilImage as! String), completed: nil
            imgProfile.sd_setImage(with: URL(string: UserDetail.profilImage as! String), completed: nil)
            //Image eklenecek ayrıca
        }
        else
        {
            if UserDetail.profilImage != nil
            {
                //imgProfile.sd_setImage(with: URL(string: UserDetail.profilImage as! String), completed: nil)
                //Çekilen resimde hata çıkarsa eğer...
                imgProfile.sd_setImage(with: URL(string: UserDetail.profilImage as! String)) { (image, error, cacheType, url) in
                    if error != nil
                    {
                        self.imgProfile.image = UIImage(named: "default_person")
                    }
                }
            }
            else
            {
                imgProfile.image = UIImage(named: "defaultPerson")
            }
            lblDeneme.text = UserDetail.email as! String ?? "Email Adresi Belirleyiniz"
            if UserDetail.username != ""
            {
                var kullaniciAdi = UserDetail.username
                txtKullaniciAdi.text = kullaniciAdi
            }
            else
            {
                //Kullanıcı Adı Olarak @ işaretine kadar olan kısmı alacağız sonra eleman isterse değiştirir.
                let indexStartOfText = UserDetail.email.index(UserDetail.email.startIndex, offsetBy: 0)
                //var email1 = UserDetail.email
                let mailIndex = UserDetail.email.index(of: "@")
                var userName = UserDetail.email[indexStartOfText..<mailIndex!]
                txtKullaniciAdi.text = String(userName)
            }
        }
        let gestureRecognizor = UITapGestureRecognizer(target: self, action: #selector(ViewControllerProfil.selectImage))
        btnProfilResimDegistir.addGestureRecognizer(gestureRecognizor)
    }
    
    @objc func selectImage()
    {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgProfile.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnKaydet(_ sender: UIBarButtonItem) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let mediaFolder = storageRef.child("ProfileImages")
        
        SVProgressHUD.show(withStatus: "Profiliniz kaydediliyor...")
        //Profil resim ve bilgilerin kaydedildiği yerdir. Tek bir yere kaydettiğinden dolayı profil altında tek bir yapıda kayıt olacaktır.
        
        if imgProfile.image == nil
        {
            imgProfile.image = UIImage(named: "default_person")
        }
        
        if let data = imgProfile.image?.jpegData(compressionQuality: 0.1)
        {
            var uuid = NSUUID().uuidString
            
            let mediaImageRef = mediaFolder.child("\(uuid).jpg")
            mediaImageRef.putData(data, metadata: nil) { (metaData, error) in
                if error != nil
                {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    mediaImageRef.downloadURL(completion: { (url, error) in
                        if error == nil
                        {
                            let databaseReference = Database.database().reference()
                            
                            var isletmemi : String = "false"
                            
                            if self.switchIsletme == true
                            {
                                isletmemi = "true"
                            }
                            else
                            {
                                isletmemi = "false"
                            }
                            
                            let postIsletme = ["AdSoyad" : self.txtAdSoyad.text ?? "", "KullaniciAdi" : self.txtKullaniciAdi.text ?? "", "ProfilResim" : url?.absoluteString ?? "", "Isletme" : self.txtGozukecekFirmaAdi.text ?? "", "Isletmemi" : isletmemi, "GizliHesap" : self.switchGizliHesap, "Motto" : self.txtMotto.text ?? ""] as [String : Any]
                            databaseReference.child("users").child(UserDetail.id).child("profile").child(UserDetail.id).setValue(postIsletme, withCompletionBlock: { (error, ref) in
                                if error != nil
                                {
                                    UserDetail.adsoayd = self.txtAdSoyad.text ?? ""
                                    UserDetail.profilImage = url?.absoluteString ?? ""
                                    UserDetail.username = self.txtKullaniciAdi.text ?? ""
                                    UserDetail.gizliHesap = self.switchGizliHesap
                                    UserDetail.motto = self.txtMotto.text ?? ""
                                    UserDetail.isletmeSahibimi = isletmemi
                                    if isletmemi == "true"
                                    {
                                        UserDetail.isletmeGozukecekAd = self.txtGozukecekFirmaAdi.text ?? ""
                                    }
                                }
                            })
                            
                            
                        }
                        else
                        {
                            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "Başarılı olarak kaydedildi")
                //Profil Düzenlemesi Bittikten Sonra Ana Sayfaya Yönlendir.
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        else
        {
            
        }
    }
    
    @IBAction func chk_IsletmesahibiOl(_ sender: UISwitch) {
        
        if sender.isOn == true
        {
            lblGozukecekAd.isHidden = false
            txtGozukecekFirmaAdi.isHidden = false
            
            switchIsletme = true
        }
        else
        {
            lblGozukecekAd.isHidden = true
            txtGozukecekFirmaAdi.isHidden = true
            
            switchIsletme = false
        }
    }
    
    
    @IBAction func chk_gizliHesap(_ sender: UISwitch) {
        
        if sender.isOn == true
        {
            switchGizliHesap = "true"
        }
        else
        {
            switchGizliHesap = "false"
        }
    }
    
    
    @IBAction func btnCikis(_ sender: UIButton) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            try Auth.auth().signOut()
            try GIDSignIn.sharedInstance()?.signOut()
            
            //Coredatadaki veriler silinir.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Login")
            fetchRequest.returnsObjectsAsFaults = false
            
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for object in results
                {
                    context.delete(object as! NSManagedObject)
                }
            }
            
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeView") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func btnGeriClick(_ sender: UIBarButtonItem) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
