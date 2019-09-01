//
//  AppDelegate.swift
//  FirebaseDemo
//
//  Created by Simon Ng on 14/12/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import FirebaseDatabase
import FBSDKCoreKit
import SVProgressHUD
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    //var myWindow : UIWindow?
    let userDefault = UserDefaults()
    var flag = "0"
    //Google ile giriş yapıldığında
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // ...
            return
        }
        else
        {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
                if error == nil
                {
                    
                    self.userDefault.set(true, forKey: "userSignedIn")
                    self.userDefault.synchronize()
                    
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
                            UserDetail.email = value?["Email"] as? String ?? ""
                            UserDetail.kullaniciVarmi = "var"
                            if self.flag == "0"
                            {
                                self.saveCoreData(GetaccessToken: Auth.auth().currentUser!.uid, GetEmail: Auth.auth().currentUser!.email!)
                                if let viewController = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                                self.flag = "1"
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                            }
                        }
                        else
                        {
                            UserDetail.username = Auth.auth().currentUser?.displayName ?? "Kullanici Adi Giriniz"
                            UserDetail.profilImage = (Auth.auth().currentUser?.photoURL?.absoluteString)!
                            UserDetail.email = Auth.auth().currentUser?.email ?? "hatavar@gmail.com"
                            UserDetail.adsoayd = Auth.auth().currentUser?.displayName ?? "Yeni Kullanici"
                            
                            //Kullancıı ilk giriş yaptığında profile kayıt atanır.
                            let postProfil = ["KullaniciAdi" : UserDetail.username ?? "", "ProfilResim" : UserDetail.profilImage , "GizliHesap" : "false", "Email" : UserDetail.email, "AdSoyad" : UserDetail.adsoayd] as [String : Any]
                            databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).child("profile").child((Auth.auth().currentUser?.uid)!).setValue(postProfil)
                            
                            self.saveCoreData(GetaccessToken: Auth.auth().currentUser!.uid, GetEmail: Auth.auth().currentUser!.email!)
                            
                            if let viewController = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "ProfileID") {
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                                self.flag = "1"
                                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                            
                            
                        }
                        
                    }) { (error) in
                        
                    }
                }
                else
                {
                    print(error?.localizedDescription)
                }
                
                
            }
        }
    }
    //Çıkış Yapıldığında-Bağlantı Kesildiğinde
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set up the style and color of the common UI elements
        //customizeUIStyle()
        
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        
        let googleHandled = GIDSignIn.sharedInstance().handle(url,
                                                              sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
        
        
        return handled || googleHandled
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SetupCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveCoreData(GetaccessToken : String, GetEmail : String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let login = NSEntityDescription.insertNewObject(forEntityName: "Login", into: context)
        login.setValue(GetaccessToken, forKey: "tokenid" )
        //tokenid
        let loginEmail = NSEntityDescription.insertNewObject(forEntityName: "Login", into: context)
        loginEmail.setValue(GetEmail, forKey: "email")
        
        do {
            try context.save()
            print("no error")
        } catch  {
            print("error")
        }
    }
    
    
    
}


extension AppDelegate {
    func customizeUIStyle() {
        
        // Customize Navigation bar items
        //UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!, NSForegroundColorAttributeName: UIColor.black], for: UIControlState.normal)
//        self.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): color]
        
        //self.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.red]

    }
}
