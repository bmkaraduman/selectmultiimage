//
//  BiletlerimCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 2.04.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

class BiletlerimCell: UITableViewCell {

    
    @IBOutlet weak var imgEvent: UIImageView!
    @IBOutlet weak var lblGun: UILabel!
    @IBOutlet weak var lblSaat: UILabel!
    @IBOutlet weak var lblDakika: UILabel!
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEventDate: UILabel!
    @IBOutlet weak var lblEventName: UILabel!
    @IBOutlet weak var lblEventYer: UILabel!
    
    @IBOutlet weak var view_ticket_detay: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
