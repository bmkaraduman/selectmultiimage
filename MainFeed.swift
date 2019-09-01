//
//  MainFeed.swift
//  FirebaseDemo
//
//  Created by macbookpro on 17.12.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

var postDateArray = [String]()


class MainFeed: UIViewController, UITableViewDataSource, UITableViewDelegate {
   

    @IBOutlet weak var tblView: UITableView!
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        
        postDateArray.append("asdasd")
        postDateArray.append("asdasd")
        postDateArray.append("asdasd")
        postDateArray.append("asdasd")
        
        //Anasayfanın girişlerini hazırlıyoruz.
        Database.database().reference().child("Categories").observe(DataEventType.childAdded, with:
            {
                (snapshot) in
                
                //let values = snapshot.value! as! NSDictionary
                let values = snapshot.value! as! NSDictionary
                let catIDs = values.allKeys

                for id in catIDs
                {
                    let singleCat = values[id] as! NSDictionary
                    postDateArray.append(singleCat["Name"] as! String)
                }
                
        }
        )

        tblView.dataSource = self
        tblView.delegate = self

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postDateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "CellMN", for: indexPath) as! MainFeedCell
        
        
        if postDateArray.count > 0
        {
            cell.mainLabel.text = postDateArray[indexPath.row] as! String
            
        }
        
        return cell
    }
    
}
