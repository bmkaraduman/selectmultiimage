//
//  BildirimFriendCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 13.05.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase

class BildirimFriendCell: UITableViewCell {

    
    @IBOutlet weak var ingProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    var getDBSc = GetDatabaseStructure()
    @IBOutlet weak var btnOnayla: UIButton!
    var index : IndexPath?
    var user_id : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnOnayla_Click(_ sender: UIButton) {
        //let date = Date()
        let databaseReference = Database.database().reference()
        btnOnayla.setImage(UIImage(named: "OnaylaDisabled"), for: .normal)
        btnOnayla.isEnabled = false
        //Arkadaşlık isteği onaylanır.
        
////        //Arkadaşlık isteğini onayladıktan sonra bildirim atılması gerekir.
////        getDBSc.BildirimAt(kimden: UserDetail.id, kime: user_id!, istekTuru: BildirimTipi.Takip_izin_ok, tarih: date, okunmaDurumu: false, ref: databaseReference)
//
        getDBSc.takipOnayla(userID: user_id!, ref: databaseReference)
        
    
        
    }
    

}
