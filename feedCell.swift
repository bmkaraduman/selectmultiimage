//
//  feedCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 4.08.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class feedCell: UITableViewCell {
    
    @IBOutlet weak var imgProfilImage: UIImageView!
        
    @IBOutlet weak var lblKonum: UILabel!
    
    @IBOutlet weak var lblEventname: UILabel!
    
    @IBOutlet weak var lblEventDate: UILabel!
    
    @IBOutlet weak var imgEventImage: UIImageView!
    
    @IBOutlet weak var lblActiveUserIDHidden: UILabel!
    
    @IBOutlet weak var btnProfilName: UIButton!
    
    @IBOutlet weak var lblLikeCount: UILabel!
    
    @IBOutlet weak var lblCommentCount: UILabel!
    
    @IBOutlet weak var lblEventId: UILabel!
    
    @IBOutlet weak var lblImLiker: UILabel!
    
    @IBOutlet weak var btnLikeTip: UIButton!
    
    @IBOutlet weak var lblEventUserID: UILabel!
    
    @IBOutlet weak var lblTarihAy: UILabel!
    
    @IBOutlet weak var lblTarihAyText: UILabel!
    
    @IBOutlet weak var imgBrand: UIImageView!
    
    @IBOutlet weak var viewDetay: UIView!
    
    var imageLink = ""
    
    var delegate:MyCustomCellDelegator!
    
    var getDBSc = GetDatabaseStructure()
    

    @IBOutlet weak var btnHeart: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnProfilClick(_ sender: UIButton) {
        
        var myData = lblActiveUserIDHidden.text

        if self.delegate != nil
        {
            self.delegate.callSegueFromCell(myData: myData as AnyObject)
        }
        
    }
    
    
    @IBAction func btnComments(_ sender: UIButton) {
        
        let eventID = lblEventId.text
        let eventUserID = lblEventUserID.text
        if self.delegate != nil
        {
            self.delegate.callCommentsFromCell(eventID: eventID as AnyObject, eventUserID : eventUserID as AnyObject)
        }
        
    }
    
    @IBAction func btnSocialPaylas(_ sender: UIButton) {
        
        let eventID = lblEventId.text as! String
        let eventName = lblEventname.text as! String
        
        self.delegate.didSharedSocial(eventID: eventID, eventName: eventName)
    }
    
    @IBAction func btnSharedFriends(_ sender: UIButton) {
        
        let eventName = lblEventname.text as! String
        let eventID = lblEventId.text as! String
        let eventUserID = lblEventUserID.text as! String
        
        self.delegate.didShareInApp(imageName: imageLink, eventName: eventName, eventID: eventID, eventUserID : eventUserID)
    }
    
    
    @IBAction func btnDigerleri(_ sender: UIButton) {
        let eventID = lblEventId.text as! String
        let eventUserID = lblEventUserID.text as! String
        
        self.delegate.didSikayet(eventID: eventID, eventUserID: eventUserID)
        
    }
    
    @IBAction func btnHeart_Click(_ sender: UIButton) {
        
        let ref = Database.database().reference()
        
        let eventID = lblEventId.text as! String
        let eventUserID = lblEventUserID.text as! String
        gl_Load = false
        
        //Beğeninin ne zaman yapıldığının tarihi
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        var begeniDurumu = "false"
        
        
        
        
        //beğeniler için bildirim atılacak.
        let likeNotify = ["Kimden" : UserDetail.id, "Kime" : eventUserID, "Tarih" : result, "Tip" : "L", "Okunma" : "false", "ID" : eventID]
        ref.child("users").child(eventUserID).child("bildirimler").childByAutoId().setValue(likeNotify)
        {
            (error, reference) in
            if error == nil
            {
                
            }
            else
            {
                //Hatayı buraya yaz
            }
        }
        if eventUserID.count > 6 && eventID.count > 6 //Bunu niye yaptım
        {
        ref.child("users").child(eventUserID).child("Event").child("Main").child(eventID).child("Like").child((UserDetail.id)).observeSingleEvent(of: .value) { (snapShot) in
                if snapShot.exists()
                {
                    //Eğer kayıt varsa ve true ise
                    let value = snapShot.value as? NSDictionary
                    ref.child("users").child(eventUserID).child("Event").child("Main").child(eventID).child("Like").child((UserDetail.id)).removeValue(completionBlock: { (error, ref) in
                        if error == nil
                        {
                            var sayi:Int = 0
                            sayi = Int(self.lblLikeCount.text!)!
                            sender.setImage(UIImage(named: "heart_empty"), for: .normal)
                            sayi = sayi - 1
                            self.lblLikeCount.text = String(describing: sayi)
                        }
                    })
                    
                }
                else
                {
                    //tip eğer 0 ise aktif yapılması gerekiyordur. Yani kalbi dolduracağız.
                    let eventBegen = ["Tarih" : result] as [String : Any]
                ref.child("users").child(eventUserID).child("Event").child("Main").child(eventID).child("Like").child((UserDetail.id)).setValue(eventBegen)
                    {
                        (error, reference)
                        in
                        if error == nil
                        {
                            var sayi:Int = 0
                            sayi = Int(self.lblLikeCount.text!)!
                            sender.setImage(UIImage(named: "heart_voll"), for: .normal)
                            sayi = sayi + 1
                            self.lblLikeCount.text = String(describing: sayi)
                        }
                    }
                }
            }
        }
    }
}
