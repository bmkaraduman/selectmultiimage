//
//  WelcomeViewController.swift
//  FirebaseDemo
//
//  Created by Simon Ng on 5/1/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn
import CoreData

struct UserDetail {
    
   static var id = ""
   static var username = ""
   static var email = ""
   static var profilImage = ""
   static var motto = ""
   static var adsoayd = ""
   static var gizliHesap = ""
   static var isletmeSahibimi = ""
   static var isletmeGozukecekAd = ""
   static var kullaniciVarmi = ""
    
}
var accessToken = String()
class WelcomeViewController: UIViewController, GIDSignInUIDelegate {

    
    @IBOutlet weak var view_login: UIView!
    
    @IBOutlet weak var view_newUser: UIView!
    
    
    @IBOutlet weak var txtPasswordRepeat: UITextField!
    
    @IBOutlet weak var txtNewUserMail: UITextField!
    
    @IBOutlet weak var txtNewUserPassword: UITextField!
    
    @IBOutlet weak var txtUserName: UITextField!
    
    @IBOutlet weak var txtEmailLogin: UITextField!
    
    @IBOutlet weak var txtSifreLogin: UITextField!
    
    
    @IBOutlet weak var segmentUserChange: UISegmentedControl!
    
    @IBOutlet weak var btnFacebook: UIButton!
    
    
    
    
    var flag = "0"
    var isAlreadyLogin = false
    //@IBOutlet weak var signInButton: GIDSignInButton!
    
    //@IBOutlet weak var googleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        
        self.hideKeyboardWhenTappedAround()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Login")
        fetchRequest.returnsObjectsAsFaults = false
        
        self.hideKeyboardWhenTappedAround()
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let coreEmail = result.value(forKey: "email") as? String
                    {
                        UserDetail.email = coreEmail
                    }
                    
                    if let tokenID = result.value(forKey: "tokenid") as? String
                    {
                        accessToken = tokenID
                        isAlreadyLogin = true
                        UserDetail.id = tokenID
                        break
                    }
                }
            }
            
        } catch  {
            print("hata")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isAlreadyLogin == true
        {
            let databaseRef = Database.database().reference()
            //(getUser, hataKodu) = getDB.getUserDetail(userID: UserDetail.id, ref: databaseRef)
            
            databaseRef.child("users").child(accessToken).child("profile").child(accessToken).observe(DataEventType.value, with: { (data) in
                if data.exists()
                {
                    let value = data.value as? NSDictionary
                    UserDetail.adsoayd = value?["AdSoyad"] as? String ?? ""
                    UserDetail.gizliHesap = value?["GizliHesap"] as? String ?? ""
                    UserDetail.isletmeGozukecekAd = value?["Isletme"] as? String ?? ""
                    UserDetail.isletmeSahibimi = value?["Isletmemi"] as? String ?? ""
                    UserDetail.motto = value?["Motto"] as? String ?? ""
                    UserDetail.profilImage = value?["ProfilResim"] as? String ?? ""
                    UserDetail.username = value?["KullaniciAdi"] as? String ?? ""
                    UserDetail.kullaniciVarmi = "var"
                    
                    if self.flag == "0"
                    {
                        self.flag = "1"
                    }
                }
                else
                {
                    //Buraya gerek yok zaten yeni profil ile
                    if let UserName = Auth.auth().currentUser?.displayName
                    {
                        UserDetail.username = UserName
                    }
                    if let ProfilLink = Auth.auth().currentUser?.photoURL
                    {
                        UserDetail.profilImage = ProfilLink.absoluteString
                    }
                    if let UserEmail = Auth.auth().currentUser?.email
                    {
                        UserDetail.email = UserEmail
                    }
                    if self.flag == "0"
                    {
                        self.flag = "1"
                    }
                }
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.flag = "1"
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (error) in
            }
        }
    }
    
    @IBAction func btnLogin_Click(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    @IBAction func SegmentedChanged(_ sender: UISegmentedControl) {
        
                let getIndex = segmentUserChange.selectedSegmentIndex
        
                switch getIndex {
                case 0:
                    view_login.isHidden = false
                    view_newUser.isHidden = true
                case 1:
                    view_login.isHidden = true
                    view_newUser.isHidden = false
                default:
                    print("Diğer Hatalar")
                }
    }
    
    func saveCoreData(GetaccessToken : String, GetEmail : String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let login = NSEntityDescription.insertNewObject(forEntityName: "Login", into: context)
        login.setValue(GetaccessToken, forKey: "tokenid" )
        
        let loginEmail = NSEntityDescription.insertNewObject(forEntityName: "Login", into: context)
        loginEmail.setValue(GetEmail, forKey: "email")
        //tokenid
        
        do {
            try context.save()
            print("no error")
        } catch  {
            print("error")
        }
    }
    
    
    
    @IBAction func btnKaydet(_ sender: UIButton) {
                if txtNewUserMail.text != "" && txtPasswordRepeat.text != "" && txtNewUserPassword.text != "" && txtUserName.text != ""
                {
                    if txtNewUserPassword.text == txtPasswordRepeat.text
                    {
                        var hata = false
                        //txtUserName.text var mı yok mu kontrol edilecek.
                        let databaseReference = Database.database().reference()
                        databaseReference.child("users").observe(.value) { (data) in
                            if data.exists()
                            {
                                let values = data.value! as! NSDictionary
                                let userIds = values.allKeys
                                for UserId in userIds
                                {
                                    //let eventUserID = userID as! String
                                    let singleUser = values[UserId] as! NSDictionary //Kullanıcı alındı. Altındaki evente ulaşılacak.
                                    if let singleUserProfile = singleUser["profile"] as! NSDictionary?
                                    {
                                        let singleProfile = singleUserProfile.value(forKey: UserId as! String) as! NSDictionary
                                        
                                        if let userProfilUserName = singleProfile["KullaniciAdi"] as! String?
                                        {
                                            if userProfilUserName == self.txtUserName.text
                                            {
                                                hata = true
                                                break
                                            }
                                        }
                                    }
                                }
                                if hata == false
                                {
                                    Auth.auth().createUser(withEmail: self.txtNewUserMail.text!, password: self.txtNewUserPassword.text!) { (userData, error) in
                                        if error != nil {
                                            let alert = UIAlertController(title: "Hata", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                                            let OkButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                                            alert.addAction(OkButton)
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        else
                                        {
                                            
                                            
                                            UserDetail.id = (Auth.auth().currentUser?.uid)!
                                            UserDetail.email = (self.txtNewUserMail.text)!
                                            
                                            
                                            //let indexStartOfText = UserDetail.email.index(UserDetail.email.startIndex, offsetBy: 0)
                                            //var email1 = UserDetail.email
                                            //let mailIndex = UserDetail.email.index(of: "@")
                                            //let userName = UserDetail.email[indexStartOfText..<mailIndex!]
                                            UserDetail.username = self.txtUserName.text!
                                            
                                            //Kullancıı ilk giriş yaptığında profile kayıt atanır.
                                            let postProfil = ["KullaniciAdi" : UserDetail.username , "GizliHesap" : "false", "Email" : UserDetail.email, "AdSoyad" : UserDetail.adsoayd] as [String : Any]
                                            databaseReference.child("users").child((Auth.auth().currentUser?.uid)!).child("profile").child((Auth.auth().currentUser?.uid)!).setValue(postProfil)
                                            
                                            self.saveCoreData(GetaccessToken: Auth.auth().currentUser!.uid, GetEmail: self.txtEmailLogin.text!)
                                            
                                            //Eğer yeni üye kaydı ise profil sayfasına gönder, değilse feed sayfasına göndereceğiz.
                                            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileID") {
                                                UIApplication.shared.keyWindow?.rootViewController = viewController
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    let alert = UIAlertController(title: "Hata", message: "Kullanıcı Adı Mevcut", preferredStyle: UIAlertController.Style.alert)
                                    let OkButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                                    alert.addAction(OkButton)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Hata", message: "Şifreler Uyuşmuyor", preferredStyle: UIAlertController.Style.alert)
                        let OkButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                        alert.addAction(OkButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Hata", message: "Alanları Boş Bırakmayınız", preferredStyle: UIAlertController.Style.alert)
                    let OkButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(OkButton)
                    self.present(alert, animated: true, completion: nil)
                }
    }
    
    
    
    @IBAction func btnGiris(_ sender: UIButton) {
                if txtEmailLogin.text != "" && txtSifreLogin.text != ""
                {
                    Auth.auth().signIn(withEmail: txtEmailLogin.text!, password: txtSifreLogin.text!) { (MyUserData, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Hata", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                            let OkButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(OkButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else
                        {
                            UserDetail.id = (Auth.auth().currentUser?.uid)!
                            UserDetail.email = (Auth.auth().currentUser?.email)!
                            
                            let databaseRef = Database.database().reference()
                            //(getUser, hataKodu) = getDB.getUserDetail(userID: UserDetail.id, ref: databaseRef)
                            
                            databaseRef.child("users").child(UserDetail.id).child("profile").child(UserDetail.id).observe(DataEventType.value, with: { (data) in
                                if data.exists()
                                {
                                    let value = data.value as? NSDictionary
                                    UserDetail.adsoayd = value?["AdSoyad"] as? String ?? ""
                                    UserDetail.gizliHesap = value?["GizliHesap"] as? String ?? ""
                                    UserDetail.isletmeGozukecekAd = value?["Isletme"] as? String ?? ""
                                    UserDetail.isletmeSahibimi = value?["Isletmemi"] as? String ?? ""
                                    UserDetail.motto = value?["Motto"] as? String ?? ""
                                    UserDetail.profilImage = value?["ProfilResim"] as? String ?? ""
                                    UserDetail.username = value?["KullaniciAdi"] as? String ?? ""
                                    UserDetail.kullaniciVarmi = "var"
                                    if self.flag == "0"
                                    {
                                        self.saveCoreData(GetaccessToken: Auth.auth().currentUser!.uid, GetEmail: UserDetail.email)
                                    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                                        UIApplication.shared.keyWindow?.rootViewController = viewController
                                        self.flag = "1"
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    }
                                }
                                else
                                {
                                    //Buraya gerek yok zaten yeni profil ile
                                        if let UserName = Auth.auth().currentUser?.displayName
                                        {
                                            UserDetail.username = UserName
                                        }
                                        if let ProfilLink = Auth.auth().currentUser?.photoURL
                                        {
                                            UserDetail.profilImage = ProfilLink.absoluteString
                                        }
                                        if let UserEmail = Auth.auth().currentUser?.email
                                        {
                                            UserDetail.email = UserEmail
                                        }
                                    if self.flag == "0"
                                    {
                                        self.saveCoreData(GetaccessToken: Auth.auth().currentUser!.uid, GetEmail: UserDetail.email)
                                        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                                            UIApplication.shared.keyWindow?.rootViewController = viewController
                                            self.flag = "1"
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            }) { (error) in
                            }
                        }
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Hata", message: "Alanları Boş Bırakmayınız", preferredStyle: UIAlertController.Style.alert)
                    let OkButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(OkButton)
                    self.present(alert, animated: true, completion: nil)
                }
    }
    
    

    @IBAction func unwindtoWelcomeView(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                else
                {
                    //var getUser = User()
                    //var hataKodu = String()
                    UserDetail.id = (Auth.auth().currentUser?.uid)!
                    UserDetail.email = (Auth.auth().currentUser?.email)!
            
                    let databaseRef = Database.database().reference()
                    databaseRef.child("users").child(UserDetail.id).child("profile").child(UserDetail.id).observe(DataEventType.value, with: { (data) in
                        if data.exists()
                        {
                           
                            let value = data.value as? NSDictionary
                            UserDetail.adsoayd = value?["AdSoyad"] as? String ?? ""
                            UserDetail.gizliHesap = value?["GizliHesap"] as? String ?? ""
                            UserDetail.isletmeGozukecekAd = value?["Isletme"] as? String ?? ""
                            UserDetail.isletmeSahibimi = value?["Isletmemi"] as? String ?? ""
                            UserDetail.motto = value?["Motto"] as? String ?? ""
                            UserDetail.profilImage = value?["ProfilResim"] as? String ?? ""
                            UserDetail.username = value?["KullaniciAdi"] as? String ?? ""
                            UserDetail.kullaniciVarmi = "var"
                            
                            // Present the main view
                            if self.flag == "0"
                            {
                                self.saveCoreData(GetaccessToken: Auth.auth().currentUser!.uid, GetEmail: UserDetail.email)
                            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                                self.flag = "1"
                                self.dismiss(animated: true, completion: nil)
                            }
                            }
                        }
                        else
                        {
                            let databaseReference = Database.database().reference()

                                UserDetail.username = (user?.displayName)!
                                UserDetail.profilImage = (user?.photoURL?.absoluteString)!
                            
                            //Kullancıı ilk giriş yaptığında profile kayıt atanır.
                            let postProfil = ["KullaniciAdi" : UserDetail.username , "ProfilResim" : UserDetail.profilImage , "GizliHesap" : "false", "Email" : UserDetail.email] as [String : Any]
                            databaseReference.child("users").child((Auth.auth().currentUser?.uid)!).child("profile").child((Auth.auth().currentUser?.uid)!).setValue(postProfil)
                            
                            self.saveCoreData(GetaccessToken: Auth.auth().currentUser!.uid, GetEmail: UserDetail.email)
                            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileID") {
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                                self.flag = "1"
                                self.dismiss(animated: true, completion: nil)
                            }
                            //ProfileID
                        }
                       
                        
                    }) { (error) in
                        
                    }
                    
                }
                
            })
            
        }   
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
