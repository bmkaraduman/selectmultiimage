//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var topButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        
        configureTableView()
 
        retrieveMessages()
     
        messageTableView.separatorStyle = .none
   
    }


    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.lblTarih.text = messageArray[indexPath.row].tarih
        var lv_profilResmi = messageArray[indexPath.row].profileImage
        if  lv_profilResmi != ""
        {
            cell.avatarImageView.sd_setImage(with: URL(string: lv_profilResmi as! String)) { (image, error, cacheType, url) in
                if error != nil
                {
                    cell.avatarImageView.image = UIImage(named: "default_person")
                }
            }
        }
        else
        {
            cell.avatarImageView.image = UIImage(named: "default_person")
        }
        lv_profilResmi = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }

    
    //TODO: Declare configureTableView here:
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
        

    }
    
    

    //MARK: - TextField Delegate Methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        
        UIView.animate(withDuration: 0.5) { 
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {

        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        if StringActiveEventID != "" || StringActiveEventID != nil
        {
            
            let messagesDB = Database.database().reference().child("Messages").child(StringActiveEventID)
            let date = Date()
            let formatter = DateFormatter()
            
            formatter.dateFormat = "dd.MM.yyyy h:s"
            let result = formatter.string(from: date)

            //Bildirimler tablosuna atılır.
            let ref = Database.database().reference()
            //beğeniler için bildirim atılacak.
            
            if StringActiveEventID != UserDetail.id
            {
                let commentNotify = ["Kimden" : UserDetail.id, "Kime" : StringActiveEventUserID, "Tarih" : result, "Tip" : "C", "Okunma" : "false", "ID" : StringActiveEventID]
                ref.child("users").child(StringActiveEventUserID).child("bildirimler").childByAutoId().setValue(commentNotify)
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
            }
            
            let messageDictionary = ["Sender": UserDetail.adsoayd,
                                     "MessageBody": messageTextfield.text!, "Tarih" : result as! String, "UserID" : UserDetail.id]
            
            
                    messagesDB.childByAutoId().setValue(messageDictionary) {
                        (error, reference) in
            
                        if error != nil {
                            print(error!)
                        }
                        else {
                            print("Message saved successfully!")
                        }
            
                        self.messageTextfield.isEnabled = true
                        self.sendButton.isEnabled = true
                        self.messageTextfield.text = ""
            
                    }
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    
    func retrieveMessages() {
        
        if StringActiveEventID != "" || StringActiveEventID != nil
        {
            let messageDB = Database.database().reference().child("Messages").child(StringActiveEventID)
            
            
            self.configureTableView()
            self.messageTableView.reloadData()
            
            
            messageDB.observe(.childAdded) { (snapshot) in
                
                let snapshotValue = snapshot.value as! Dictionary<String,String>
                let text = snapshotValue["MessageBody"]!
                let sender = snapshotValue["Sender"]!
                let tarih = snapshotValue["Tarih"]!
                let UserID = snapshotValue["UserID"]!
                
                
                
                let message = Message()
                message.messageBody = text
                message.sender = sender
                message.tarih = tarih
                
               let databaseReference = Database.database().reference()
                databaseReference.child("users").child(UserID).child("profile").child(UserID).observe(DataEventType.value, with: { (data) in
                    if data.exists()
                    {
                        
                        let value = data.value as? NSDictionary
                        
                        message.profileImage = value?["ProfilResim"] as? String ?? ""
                    }
                    print(UserID)
                    self.messageArray.append(message)
                    
                    
                    self.configureTableView()
                    self.messageTableView.reloadData()
                })
            }
        }

    }

}
