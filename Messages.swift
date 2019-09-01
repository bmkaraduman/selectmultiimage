//
//  Messages.swift
//  FirebaseDemo
//
//  Created by macbookpro on 24.09.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SVProgressHUD

class Messages: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    //var takipcilerim = [Takipci]()
    var myMessages = [MessageCellClass]()
    var chatUsers = [String]()
    
    @IBOutlet weak var viewMessages: UIView!
    @IBOutlet weak var lblMessages: UILabel!
    
    
    @IBOutlet weak var tblMessagesView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        
        tblMessagesView.delegate = self
        tblMessagesView.dataSource = self
        //self.navigationController?.title = "Chat Listesi"
        
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [NSAttributedString.Key : Any])
        
        //Burada chat yapılan tüm kullanıcılara erişmeye çalışıyoruz.
        let databaseReference = Database.database().reference()
        SVProgressHUD.show(withStatus: "Etkinlikler getiriliyor...")
        _ = databaseReference.child("chat").observe(.value) { (data) in
            
            //Eğer Chat'in altında, giriş yapan kullanıcılar varsa alınır.
            if data.hasChild(UserDetail.id)
            {
                let value = data.value! as! NSDictionary
                let userMessagesStructure = value[UserDetail.id] as! NSDictionary
                let userMessagesUsers = userMessagesStructure.allKeys
                
                for user in userMessagesUsers
                {
                    let singleUser = user as! String
                    
                    let varMi = self.chatUsers.contains(where: { (kkk) -> Bool in
                        kkk == singleUser
                    })
                    print("aaa" + singleUser)
                    if varMi == false
                    {
                        self.chatUsers.append(singleUser)
                    }
                }
            }
            
            if self.chatUsers.count == 0
            {
                self.viewMessages.isHidden = false
                self.tblMessagesView.isHidden = true
            }
            else
            {
                self.viewMessages.isHidden = true
                self.tblMessagesView.isHidden = false
            }
            
            let otherValue = data.value! as! NSDictionary
            let allIds = otherValue.allKeys //Chatin altındaki userlar alınır.
                
            for firstUser in allIds //Tüm userlar dolaşılır
            {
                let belowUserStructure = otherValue[firstUser] as! NSDictionary //User user structurea atılır.
                    let belowUsers = belowUserStructure.allKeys //Userın altındaki userlara bakılır
                    for secondUser in belowUsers //Userlar içinde dönülür
                    {
                        let secondUserString = secondUser as! String
                        if secondUserString == UserDetail.id //Eğer giriş yapılan kullanıcı farsa alınır.
                        {
                            self.chatUsers.append(firstUser as! String)
                            let kl = firstUser as! String
                            print("bbb" + kl)
                            break
                        }
                    }
                    
                }
            
            for cUser in self.chatUsers
            {
                let singleMessage = MessageCellClass()
                _ = databaseReference.child("users").child(cUser).child("profile").child(cUser).observe(.value, with: { (dataUser) in
                    
                    let valueDataUser = dataUser.value as? NSDictionary
                    singleMessage.Image = valueDataUser?["ProfilResim"] as? String ?? ""
                    singleMessage.UserName = valueDataUser?["AdSoyad"] as? String ?? ""
                    if singleMessage.UserName == ""
                    {
                        singleMessage.UserName = valueDataUser?["KullaniciAdi"] as? String ?? ""
                    }
                    singleMessage.takerUser = cUser
                    let kl = self.myMessages.contains(where: { (MessageCellClass) -> Bool in
                        MessageCellClass.takerUser == cUser
                    })
                    
                    if kl == false
                    {
                        self.myMessages.append(singleMessage)
                    }
                    
                    self.tblMessagesView.reloadData()
                })
            }
            
            SVProgressHUD.dismiss()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myMessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMessagesView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
    
        if myMessages.count > 0
        {
            let resim = myMessages[indexPath.row].Image
            if resim != ""
            {
                cell.imgUser.layer.cornerRadius = cell.imgUser.frame.height / 2
                cell.imgUser.layer.masksToBounds = true
                cell.imgUser.contentMode = .scaleAspectFill
                cell.imgUser.layer.masksToBounds = true
                
                
                cell.imgUser.sd_setImage(with: URL(string: resim)) { (img, err, cachType, url) in
                    if err != nil
                    {
                        cell.imgUser.image = UIImage(named: "default_person")
                    }
                }
            }
            else
            {
                cell.imgUser.image = UIImage(named: "default_person")
            }
            
            cell.imgUserName.text = myMessages[indexPath.row].UserName
            //cell.lblLastMessage.text = myMessages[indexPath.row].LastMessage as! String
            //cell.lblLastMessageDate.text = myMessages[indexPath.row].LastmessageDate as! String
        }
        return cell
    }
    
    var transferMessageUser = MessageCellClass()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ps_chat"
        {
            //let destinationVC = segue.destination as! Chat
            StringActiveUserID = transferMessageUser.takerUser
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transferMessageUser.takerUser = myMessages[indexPath.row].takerUser
        performSegue(withIdentifier: "ps_chat", sender: nil)
    }
    

}
