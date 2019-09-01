//
//  MessageCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 18.03.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
