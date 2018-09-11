//
//  ViewController.swift
//  SaveMoreThanOneImage
//
//  Created by macbookpro on 11.09.2018.
//  Copyright © 2018 Metin KARADUMAN. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var flag = 0
    @IBOutlet weak var btn1: UIButton!
    
    @IBOutlet weak var btn2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func btn1Click(_ sender: UIButton) {
        
        flag = 1
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = .photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true)
        {
            
        }
    }
    
    @IBAction func btn2Click(_ sender: UIButton) {
        flag = 2
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = .photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true)
        {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            
            if flag == 1
            {
                btn1.setBackgroundImage(image, for: .normal)
            }
            else if flag == 2
            {
                btn2.setBackgroundImage(image, for: .normal)
            }

        }
        
        self.dismiss(animated: true, completion: nil)
        
        
    }


}

