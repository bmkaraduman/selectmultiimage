//
//  EventMessageCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 25.06.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit


protocol MessageDelegate {
    func getEventFromServer(eventID : String, eventUserId : String)
}


class EventMessageCell: UITableViewCell {

    
    @IBOutlet weak var imageEvent: UIImageView!
    
    @IBOutlet weak var lblEventAdi: UILabel!
    
    @IBOutlet weak var btnImage: UIButton!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var messageBacckGround: UIView!
    
    var delegate:MessageDelegate?
    //var delegate:MyCustomCellDelegator!
    var eventID = ""
    var eventUserID = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnImage_Click(_ sender: UIButton) {
        if delegate != nil
        {
            //Bu Cell'in oluştuğu Chat controllerde metot detayı mevcut. Delegatelerde dikkat edilmesi gereken konu, tableview oluşturulurken, cell'e de delegatein atanması... cell.delegate = self
            delegate?.getEventFromServer(eventID: eventID, eventUserId: eventUserID)
        }
    }
    
    
}
