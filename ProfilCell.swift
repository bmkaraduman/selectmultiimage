//
//  ProfilCell.swift
//  FirebaseDemo
//
//  Created by macbookpro on 9.01.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

protocol TableViewNew {
    func onClickCell(index : Int, tip : String, button : UIButton)
}



class ProfilCell: UITableViewCell {

    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var btnTakiple: UIButton!
    
    @IBOutlet weak var lblTakipEdilenHiddenTasiyici: UILabel!
    
    @IBOutlet weak var lblTakipciHiddenTasiyici: UILabel!
    
    @IBOutlet weak var lblTakipDurumHidden: UILabel!
    
    @IBOutlet weak var lblTakipciDurumHidden: UILabel!
    
    var getDBSc = GetDatabaseStructure()
    
    var cellDelegate : TableViewNew?
    var index : IndexPath?
    
    var user_id : String?
    var durum : String?
    var gizlimi : String?
    
    var whichTableView : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnTakiple(_ sender: UIButton) {
        let databaseReference = Database.database().reference()
        gl_Load = false
        let date = Date()
        //print("En başta" + lblTakipDurumHidden.text! + "Kullanıcı" + lblUserName.text!)
        if whichTableView == "takip"
        {
            if lblTakipDurumHidden.text == "0" //Hemen takip etmek için - 0 - Takip Et Butonu
            {
                //Takip Bırakma Eylemi oLur- TakipEt butonu olur - Durum 1'e getirilir.
                //getDBSc.takipBirak(userID: user_id!, ref: databaseReference, btn: sender, tip: lblTakipDurumHidden)
                databaseReference.child("users").child(UserDetail.id).child("Following").child(user_id!).removeValue { (error, DataRef) in
                    if (error != nil)
                    {
                        print(error)
                    }
                    else
                    {
                        onayIslemiVarmi = "false"
                        self.lblTakipDurumHidden.text = "1"
                        //btn.imageView?.image = UIImage(named: "takipetmavi")
                        sender.setImage(UIImage(named: "takipetmavi"), for: .normal)
                    }
                    print("Sonra" + self.lblTakipDurumHidden.text! + "Kullanıcı" + self.lblUserName.text!)
                }
            }
            else if lblTakipDurumHidden.text == "1" //Takibi Bırak Butonu
            {

                if gizlimi == "false"
                {
                    getDBSc.BildirimAt(kimden: UserDetail.id, kime: user_id!, istekTuru: BildirimTipi.Takip_ettim, tarih: date, okunmaDurumu: false, ref: databaseReference)
                }
                else
                {
                    getDBSc.BildirimAt(kimden: UserDetail.id, kime: user_id!, istekTuru: BildirimTipi.Takip_izin, tarih: date, okunmaDurumu: false, ref: databaseReference)
                }
                
                
                let postTakipEt = ["onaygerekli" : gizlimi]
                databaseReference.child("users").child(UserDetail.id).child("Following").child(user_id!).setValue(postTakipEt) { (error, reference) in
                    
                    if (error != nil)
                    {
                    }
                    else
                    {
                        onayIslemiVarmi = "true"
                        
                        if self.gizlimi == "true"
                        {
                            sender.setImage(UIImage(named: "iletildi"), for: .normal)
                            self.lblTakipDurumHidden.text = "3"
                        }
                        else
                        {
                            sender.setImage(UIImage(named: "birak"), for: .normal)
                            self.lblTakipDurumHidden.text = "0"
                        }
                    }
                    print("Sonra" + self.lblTakipDurumHidden.text! + "Kullanıcı" + self.lblUserName.text!)
                }
                
                
                
            }
            else if lblTakipDurumHidden.text == "3"//Bu zaten loadta iletildi butonu idi, tıklandığında takibi bırakacak, takip et butonu olacak.
            {
                //getDBSc.takipBirak(userID: user_id!, ref: databaseReference, btn: sender, tip: lblTakipDurumHidden)
                databaseReference.child("users").child(UserDetail.id).child("Following").child(user_id!).removeValue { (error, DataRef) in
                    if (error != nil)
                    {
                        print(error)
                    }
                    else
                    {
                        onayIslemiVarmi = "false"
                        self.lblTakipDurumHidden.text = "1"
                        //btn.imageView?.image = UIImage(named: "takipetmavi")
                        sender.setImage(UIImage(named: "takipetmavi"), for: .normal)
                        print("Sonra" + self.lblTakipDurumHidden.text! + "Kullanıcı" + self.lblUserName.text!)
                    }
                }
            }
            
        }
        else
        {
            if lblTakipciDurumHidden.text == "0" //Hemen takip etmek için - 0 - Takip Et Butonu
            {
                //Takip Bırakma Eylemi oLur- TakipEt butonu olur - Durum 1'e getirilir.
                getDBSc.takipBirak(userID: user_id!, ref: databaseReference, btn: sender, tip: lblTakipciDurumHidden)
            }
            else if lblTakipciDurumHidden.text == "1" //Takibi Bırak Butonu
            {
                getDBSc.takipEt(userID: user_id!, gizliHesap: gizlimi ?? "false", ref: databaseReference, btn: sender, imageName: "birak", tip: lblTakipciDurumHidden)
            }
            else if lblTakipciDurumHidden.text == "3"//Bu zaten loadta iletildi butonu idi, tıklandığında takibi bırakacak, takip et butonu olacak.
            {
                getDBSc.takipBirak(userID: user_id!, ref: databaseReference, btn: sender, tip: lblTakipciDurumHidden)
            }
        }
    }

}
