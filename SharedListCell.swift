//
//  SharedListCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 22.06.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

var userList = [String]()
protocol ChangeButtonDelegator {
    func callValueFromCell(selected : Bool)
}

class SharedListCell: UITableViewCell {

    var userID = ""
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var imgProfileName: UILabel!
    
    @IBOutlet weak var btnSelected: UIButton!
    
    var cellButtonDelegate : ChangeButtonDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnSelected_Click(_ sender: UIButton) {
        
        if btnSelected.tag == 1
        {
            btnSelected.backgroundColor = UIColor.flatBlue()
            btnSelected.tag = 2
            userList.append(userID)
        }
        else
        {
            btnSelected.backgroundColor = UIColor.flatWhite()
            btnSelected.tag = 1
            userList.removeAll { (kk) -> Bool in
                kk == userID
            }
        }
        
        if userList.count == 0
        {
            cellButtonDelegate.callValueFromCell(selected: false)
        }
        else
        {
            cellButtonDelegate.callValueFromCell(selected: true)
        }
        
    }
}
