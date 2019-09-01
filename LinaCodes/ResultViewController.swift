//
//  ResultViewController.swift
//  Lina
//
//  Created by macbookpro on 17.08.2019.
//  Copyright © 2019 Metin KARADUMAN. All rights reserved.
//

import Foundation
import UIKit

class ResultViewController : UIViewController
{
    
    let backGroundImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Background_Lena"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let firstPageImage : UIImageView = {
        let imageLogo = UIImageView(image: UIImage(named: "Logo"))
        imageLogo.translatesAutoresizingMaskIntoConstraints = false
        return imageLogo
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
        view.addSubview(backGroundImageView)
        view.addSubview(firstPageImage)
        
        
        
        
        
    }
    
    func setupLayout()
    {
        
    }
    
    
    
}
