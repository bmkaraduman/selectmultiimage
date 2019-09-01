//
//  SharedList.swift
//  FirebaseDemo
//
//  Created by macbookpro on 22.06.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class SharedList: UIViewController, UITableViewDataSource, UITableViewDelegate, ChangeButtonDelegator {
    
    @IBOutlet weak var btnShareListButton: UIButton!
    
    @IBOutlet weak var view_liste: UIView!
    
    @IBOutlet weak var view_nofriends: UIView!
    
    var eventUserList = [eventUser]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sendFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewSharedList.dequeueReusableCell(withIdentifier: "cellShared", for: indexPath) as! SharedListCell
        cell.imgProfileName.text = sendFriends[indexPath.row].userName
        cell.userID = sendFriends[indexPath.row].userID
        cell.imgProfile.sd_setImage(with: URL(string: sendFriends[indexPath.row].userImage), completed: nil)
        
        cell.cellButtonDelegate = self
        
        cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.height / 2
        cell.imgProfile.layer.masksToBounds = true
        cell.imgProfile.contentMode = .scaleToFill
        
        cell.btnSelected.layer.cornerRadius = cell.btnSelected.frame.height / 2
        cell.btnSelected.layer.masksToBounds = true
        cell.btnSelected.contentMode = .scaleToFill
        
        cell.btnSelected.layer.borderWidth = 1
        cell.btnSelected.layer.borderColor = UIColor.flatBlue()?.cgColor
        cell.btnSelected.backgroundColor = UIColor.flatWhite()
        cell.btnSelected.tag = 1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    @IBOutlet weak var tblViewSharedList: UITableView!
    
    var sendFriends  = [moreFriends]()
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        userList.removeAll()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.ShowAnimate()
        
        var onayDurumu = ""
        let databaseReference = Database.database().reference()
        
        self.tblViewSharedList.delegate = self
        self.tblViewSharedList.dataSource = self
        self.tblViewSharedList.separatorStyle = .none
        
        
        self.view_nofriends.isHidden = false
        self.view_liste.isHidden = false
        
        self.view_liste.layer.cornerRadius = 10
        
        databaseReference.child("users").child(UserDetail.id).child("Following").observe(DataEventType.value) { (data) in
            if data.exists()
            {
                let value = data.value as? NSDictionary
                let postIds = value?.allKeys
                
                for id in postIds!
                {
                    let idString = id as! String
                    print(idString)
                    let followingID = value![id] as! NSDictionary
                    onayDurumu = followingID["onaygerekli"] as? String ?? ""
                    
                    if onayDurumu == "false" //Onayın gerekli olmadığı belirtiliyor.
                    {
                        //Mevcut kullanıcıyı değil, StringActiveUserID alınacak.
                        databaseReference.child("users").child(idString).child("profile").child(idString).observe(DataEventType.value, with: { (data) in
                            if data.exists()
                            {
                                var friendsClass = moreFriends()
                                let value = data.value as? NSDictionary
                                
                                friendsClass.userName = value!["AdSoyad"] as? String ?? ""
                                
                                if friendsClass.userName == ""
                                {
                                    friendsClass.userName = value!["KullaniciAdi"] as? String ?? ""
                                }
                                
                                friendsClass.userID = idString
                                friendsClass.userImage = value!["ProfilResim"] as? String ?? ""
                                
                                let varmi = self.sendFriends.contains(where: { (moreFriends) -> Bool in
                                    moreFriends.userID == idString
                                })
                                
                                if varmi == false
                                {
                                    self.sendFriends.append(friendsClass)
                                }
                            }
                            if self.sendFriends.count > 0
                            {
                                self.view_nofriends.isHidden = true
                                self.view_liste.isHidden = false
                                self.tblViewSharedList.reloadData()
                            }
                            
                            
                        })
                    }
                }
                
        }
    }

}
    
    
    @IBAction func btnProfilindePaylas(_ sender: UIButton) {

        //Seçilen tüm liste alınır. Döngü içerisine alınır. StringActiveUserID yerine o id yazılır.
        let databaseReference = Database.database().reference()
        var chatDB = DatabaseReference()
        
        if userList.count == 0
        {
            //SharedListe taşıyacağız.
            let ref = Database.database().reference()
            SVProgressHUD.show(withStatus: "Profilinizde Paylaşılıyor...")
            
            let postEvent = ["eventID" : selectedEventID, "userID" : UserDetail.id]
            ref.child("users").child(UserDetail.id).child("Shared").child(selectedEventID).setValue(postEvent) { (error, DataRef) in
                if error != nil
                {
                    SVProgressHUD.showError(withStatus: "Ooops Hata Oluştu")
                }
                else
                {
                    SVProgressHUD.showSuccess(withStatus: "Profilinizde Paylaşıldı")
                    self.removeAnimate()
                }
            }
        }
        else
        {
            for getUser in userList
            {
               let dahaOnceEklendiMi = eventUserList.contains { (eventUser) -> Bool in
                    eventUser.eventID == selectedEventID && eventUser.userID == getUser
                }
                if dahaOnceEklendiMi == false
                {
                    let chatUsers = databaseReference.child("chat").child(getUser as! String).child(UserDetail.id).observe(.value) { (data) in
                        //1. Ben B kullanıcısıysam ve A kişisiyle yazışacaksam eğer, öncelikle A altında B var mı diye bakılır.
                        if data.exists()
                        {
                            //varsa eğer mesaj buraya yazılır.
                            chatDB = Database.database().reference().child("chat").child(getUser).child(UserDetail.id)
                        }
                        else
                        {
                            //2. Yoksa eğer B altına A yazılır.
                            chatDB = Database.database().reference().child("chat").child(UserDetail.id).child(getUser)
                        }
                        
                        let date = Date()
                        let formatter = DateFormatter()
                        
                        formatter.dateFormat = "dd.MM.yyyy h:s"
                        let result = formatter.string(from: date)
                        let messageDictionary = ["Sender": UserDetail.adsoayd,
                                                 "MessageBody": selectedEventName, "Tarih" : result , "UserID" : UserDetail.id, "EventImage" : selectedEventImage, "EventID" : selectedEventID, "EventUserID" : selectedEventUserId]
                        
                        chatDB.childByAutoId().setValue(messageDictionary) {
                            (error, reference) in
                            
                            if error != nil {
                                print(error!)
                            }
                            else {
                                var eventuser = eventUser()
                                eventuser.userID = getUser
                                eventuser.eventID = selectedEventID
                                self.eventUserList.append(eventuser)
                                
                                userList.removeAll()
                                SVProgressHUD.showSuccess(withStatus: "Paylaşıldı")
                                self.removeAnimate()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func iptal_click(_ sender: UIButton) {
        self.removeAnimate()
        //self.removeFromParent()
    }
    
    func ShowAnimate()
    {
        self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }
        
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }) { (finished) in
            if finished == true
            {
                self.view.removeFromSuperview()
            }
        }
    }
    
    func callValueFromCell(selected: Bool) {
        if selected == true
        {
            btnShareListButton.setImage(UIImage(named: "ShareMessage"), for: .normal)
        }
        else
        {
            btnShareListButton.setImage(UIImage(named: "ShareProfile"), for: .normal)
        }
    }
}
