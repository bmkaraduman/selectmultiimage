//
//  SideBarController.swift
//  NewProjectSideBar
//
//  Created by macbookpro on 14.12.2018.
//  Copyright © 2018 Metin KARADUMAN. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import GoogleSignIn

var biletKontrolMu = false

class SideBarController: UIViewController {

    var sidebarView: SidebarView!
    var blackScreen: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func addSlideMenuButton()
    {
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        let btnMenu = UIBarButtonItem(image: #imageLiteral(resourceName: "SolMenu111"), style: .plain, target: self, action: #selector(btnMenuAction))
        
        //btnMenu.width = 24
        
        btnMenu.tintColor=UIColor(red: 54/255, green: 55/255, blue: 56/255, alpha: 1.0)
        self.navigationItem.leftBarButtonItem = btnMenu
        //nvItem.leftBarButtonItem = btnMenu
    
        sidebarView=SidebarView(frame: CGRect(x: 0, y: 0, width: 0, height: self.view.frame.height))
        sidebarView.delegate=self
        sidebarView.layer.zPosition=80
        self.view.isUserInteractionEnabled=true
        //self.view.addSubview(sidebarView)
        currentWindow?.isUserInteractionEnabled = true
        currentWindow?.addSubview(sidebarView)
        
        
        blackScreen=UIView(frame: self.view.bounds)
        blackScreen.backgroundColor=UIColor(white: 0, alpha: 0.5)
        blackScreen.isHidden=true
        
        currentWindow?.addSubview(blackScreen)
        //self.view.addSubview(blackScreen)
        
        blackScreen.layer.zPosition=99
        let tapGestRecognizer = UITapGestureRecognizer(target: self, action: #selector(blackScreenTapAction(sender:)))
        blackScreen.addGestureRecognizer(tapGestRecognizer)
    }
    
    @objc func btnMenuAction() {
        blackScreen.isHidden=false
        UIView.animate(withDuration: 0.3, animations: {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 250, height: self.sidebarView.frame.height)
        }) { (complete) in
            self.blackScreen.frame=CGRect(x: self.sidebarView.frame.width, y: 0, width: self.view.frame.width-self.sidebarView.frame.width, height: self.view.bounds.height+100)
            //self.blackScreen.bringSubviewToFront((self.navigationController?.navigationItem.titleView)!)
        }
    }
    
    @objc func blackScreenTapAction(sender: UITapGestureRecognizer) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
    }


}


extension SideBarController: SidebarViewDelegate {
    func sidebarDidSelectRow(row: Row) {
        blackScreen.isHidden=true
        blackScreen.frame=self.view.bounds
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.frame=CGRect(x: 0, y: 0, width: 0, height: self.sidebarView.frame.height)
        }
        switch row {
        case .viewControllerProfil:
            //let vc=ViewControllerProfil()
            //self.navigationController?.pushViewController(vc, animated: true)
            //self.present(vc, animated: true, completion: nil)
            
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileID") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }

        case .UploadEvents:
            yeniSayfa = true
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EtkinlikYukle") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        case .ticketListController :
            biletKontrolMu = true
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ticketControl") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        case .ticketListController2 :
            biletKontrolMu = false
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ticketControl") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
//        case .MyProfile:
//            StringActiveUserID = UserDetail.id
//            self.tabBarController!.selectedIndex = 4
        case .exit :
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
            
            
        case .none:
            break
        }
    }
}
