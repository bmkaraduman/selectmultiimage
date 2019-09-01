//
//  addImages.swift
//  FirebaseDemo
//
//  Created by macbookpro on 23.11.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Photos

class addImages: UIViewController {

    //Çoklu Resim Seçme
    var SelectedAssets = [PHAsset]()
    //var PhotoArray = [UIImage]()
    
    @IBOutlet weak var imgView1: UIImageView!
    
    @IBOutlet weak var imgView2: UIImageView!
    
    @IBOutlet weak var imgView3: UIImageView!
    
    @IBOutlet weak var imgView4: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let photoArrayCount = PhotoArray.count
        
        if photoArrayCount == 1 {
            imgView1.image = PhotoArray[0]
            
            imgView2.tag = 1
            imgView3.tag = 1
            imgView4.tag = 1
        }
        else if photoArrayCount == 2 {
            imgView1.image = PhotoArray[0]
            imgView2.image = PhotoArray[1]
            
            imgView3.tag = 1
            imgView4.tag = 1
        }
        else if photoArrayCount == 3
        {
            imgView1.image = PhotoArray[0]
            imgView2.image = PhotoArray[1]
            imgView3.image = PhotoArray[2]
            
            imgView4.tag = 1
        }
        else if photoArrayCount == 4
        {
            imgView1.image = PhotoArray[0]
            imgView2.image = PhotoArray[1]
            imgView3.image = PhotoArray[2]
            imgView4.image = PhotoArray[3]
        }
        
    }
    
//Artık kullanılmayacak
//    @IBAction func UploadImages(_ sender: UIButton) {
//
//        //Mevcut seçili olan resimler zaten seçildiği için seçilmeyecek.
//        var selectablePhotoCount = 4 - PhotoArray.count
//
//
//        let vc = BSImagePickerViewController()
//        vc.maxNumberOfSelections = selectablePhotoCount
//        //display picture gallery
//        self.bs_presentImagePickerController(vc, animated: true,
//                                             select: { (asset: PHAsset) -> Void in
//
//        }, deselect: { (asset: PHAsset) -> Void in
//            // User deselected an assets.
//
//        }, cancel: { (assets: [PHAsset]) -> Void in
//            // User cancelled. And this where the assets currently selected.
//        }, finish: { (assets: [PHAsset]) -> Void in
//            // User finished with these assets
//            for i in 0..<assets.count
//            {
//                self.SelectedAssets.append(assets[i])
//            }
//
//            self.convertAssetToImages()
//
//        }, completion: nil)
//    }
    
    
    @IBAction func delete_image1(_ sender: UIButton) {
        if PhotoArray.firstIndex(of: imgView1.image!) ?? -2 > -1 {
        PhotoArray.remove(at: PhotoArray.firstIndex(of: imgView1.image!)!)
        imgView1.image = UIImage(named: "ResimEkle")!
        imgView1.tag = 1
        }
    }
    
    @IBAction func delete_image2(_ sender: UIButton) {
        if PhotoArray.firstIndex(of: imgView2.image!) ?? -2 > -1 {
        PhotoArray.remove(at: PhotoArray.firstIndex(of: imgView2.image!)!)
        imgView2.image = UIImage(named: "ResimEkle")!
        imgView2.tag = 1
        }
    }
    
    @IBAction func delete_image3(_ sender: UIButton) {
        if PhotoArray.firstIndex(of: imgView3.image!) ?? -2 > -1 {
        PhotoArray.remove(at: PhotoArray.firstIndex(of: imgView3.image!)!)
        imgView3.image = UIImage(named: "ResimEkle")!
        imgView3.tag = 1
        }
    }
    
    @IBAction func delete_image4(_ sender: UIButton) {
        if PhotoArray.firstIndex(of: imgView4.image!) ?? -2 > -1 {
        PhotoArray.remove(at: PhotoArray.firstIndex(of: imgView4.image!)!)
        imgView4.image = UIImage(named: "ResimEkle")!
            imgView4.tag = 1
        }
    }
    
    func convertAssetToImages() -> Void {
        
        if SelectedAssets.count != 0{
            
            
            for i in 0..<SelectedAssets.count{
                
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                
                
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                    
                })

                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                if imgView1.tag == 1
                {
                    imgView1.image = newImage
                    imgView1.tag = 2
                }
                else if imgView2.tag == 1
                {
                    imgView2.image = newImage
                    imgView2.tag = 2
                }
                else if imgView3.tag == 1
                {
                    imgView3.image = newImage
                    imgView3.tag = 2
                }
                else if imgView4.tag == 1
                {
                    imgView4.image = newImage
                    imgView4.tag = 2
                }
                
                PhotoArray.append(newImage! as UIImage)
            }
        }
        print("complete photo array \(PhotoArray)")
    }
    
    @IBAction func BackToUploadEvents(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "vw_addImages_uploadEvents", sender: nil)
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "vw_addImages_uploadEvents"
//        {
//            let destinationAddImages2 = segue.destination as! UploadEvents
//            destinationAddImages2.PhotoArray = PhotoArray
//        }
//    }
    
    @IBAction func BackToPrvScreen(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
