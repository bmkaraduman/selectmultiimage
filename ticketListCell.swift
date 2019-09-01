//
//  ticketListCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 14.04.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

class ticketListCell: UITableViewCell {

    @IBOutlet weak var imgTicketImage: UIImageView!
    
    @IBOutlet weak var lblTicketName: UILabel!
    
    @IBOutlet weak var lblTicketTarih: UILabel!
    
    @IBOutlet weak var lblSuresi: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
