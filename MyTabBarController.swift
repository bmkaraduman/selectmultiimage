//
//  MyTabBarController.swift
//  FirebaseDemo
//
//  Created by macbookpro on 23.07.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import SDWebImage

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        self.delegate = self

    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        StringActiveUserID = ""
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print("Selected view controller")
    }

}
