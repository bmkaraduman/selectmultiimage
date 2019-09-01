//
//  BegeniBildirimCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 23.04.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

class BegeniBildirimCell: UITableViewCell {

    
    @IBOutlet weak var imgProfil: UIImageView!
    
    @IBOutlet weak var lblBildirimMessage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
