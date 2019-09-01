//
//  MoreFriendsTableView.swift
//  FirebaseDemo
//
//  Created by macbookpro on 28.05.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

class MoreFriendsTableView: UITableViewController {

    
    @IBOutlet var tblViewMoreFriends: UITableView!
    //var moreFriendListTV = [moreFriends]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black]
                    self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [NSAttributedString.Key : Any])
        
        
        tblViewMoreFriends.delegate = self
        tblViewMoreFriends.dataSource = self

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return moreFriendList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellMoreFriends", for: indexPath) as! MoreFriendsTableViewCell
        
        cell.lblProfilName.text = moreFriendList[indexPath.row].userName
        cell.imgProfilImage.sd_setImage(with: URL(string: moreFriendList[indexPath.row].userImage), completed: nil)
        // Configure the cell...

        cell.imgProfilImage.layer.cornerRadius = cell.imgProfilImage.frame.height / 2
        cell.imgProfilImage.layer.masksToBounds = true
        cell.imgProfilImage.contentMode = .scaleAspectFill
        
        
        // add border and color
        cell.backgroundColor = UIColor.flatSkyBlue()
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 5
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        StringActiveUserID = moreFriendList[indexPath.row].userID
        performSegue(withIdentifier: "ps_mfriends_dfriends", sender: nil)
    }
 

    @IBAction func btnGeri_Click(_ sender: UIBarButtonItem) {
        
      self.dismiss(animated: true, completion: nil)
        
    }
    


}
