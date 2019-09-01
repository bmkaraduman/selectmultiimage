//
//  Sidebar.swift
//  mySidebar2
//
//  Created by Muskan on 10/12/17.
//  Copyright © 2017 akhil. All rights reserved.
//

import Foundation
import UIKit

protocol SidebarViewDelegate: class {
    func sidebarDidSelectRow(row: Row)
}

enum Row: String {
    case viewControllerProfil
    case UploadEvents
    case ticketListController
    case ticketListController2
    case exit
    case none
    
    init(row: Int) {
        switch row {
        case 0: self = .viewControllerProfil
        case 1: self = .UploadEvents
        case 2 : self = .ticketListController
        case 3 : self = .ticketListController2
        case 4 : self = .none
        case 5 : self = .none
        case 6 : self = .exit
        default: self = .none
        }
    }
}

class SidebarView: UIView, UITableViewDelegate, UITableViewDataSource {

    var titleArr = [String]()
    var imageArr = [String]()
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    weak var delegate: SidebarViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor=UIColor.white
        self.clipsToBounds=true
        
        //Yetkiye Göre ayırt et burayı --- Eğer Admin İse...
        //titleArr = ["Akhilendra Singh", "Messages", "Contact", "Settings", "1", "2", "3"]
        //imageArr = ["", "PlayIcon", "istatistik", "Cikis"]
        if UserDetail.adsoayd != "" && UserDetail.adsoayd != nil
        {
            if UserDetail.adsoayd.count > 0
            {
                arrayMenuOptions.append(["title":UserDetail.adsoayd, "icon":""])
            }
            else
            {
                arrayMenuOptions.append(["title":UserDetail.username, "icon":""])
            }
        }
        else
        {
            arrayMenuOptions.append(["title":UserDetail.username, "icon":""])
        }
    
        arrayMenuOptions.append(["title":"Etkinlik Yükle", "icon":"NewEvent"])
        arrayMenuOptions.append(["title":"Bilet Kontrolü", "icon":"TicketControl"])
        arrayMenuOptions.append(["title":"Etkinliklerim", "icon":"EventStatistics"])
        arrayMenuOptions.append(["title":"Etkinlik Adresleri", "icon":"map"])
        arrayMenuOptions.append(["title":"Kayıtlı Kartlarım", "icon":"SavedCards"])
        arrayMenuOptions.append(["title":"Çıkış Yap", "icon":"LogOff"])
        
        
        setupViews()
        
        myTableView.delegate=self
        myTableView.dataSource=self
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        myTableView.tableFooterView=UIView()
        myTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        myTableView.allowsSelection = true
        myTableView.bounces=false
        myTableView.showsVerticalScrollIndicator=false
        myTableView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenuOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            
            let newView = UIView(frame: CGRect(x: 0, y: 20, width: 280, height: 225))
            newView.backgroundColor = UIColor(red: 74/255, green: 137/255, blue: 218/255, alpha: 1.0)
            //cell.backgroundColor=UIColor(red: 74/255, green: 137/255, blue: 218/255, alpha: 1.0)
            let cellImg: UIImageView!
            cellImg = UIImageView(frame: CGRect(x: 40, y: 45, width: 66, height: 66))
            cellImg.layer.cornerRadius = cellImg.frame.height / 2
            cellImg.layer.masksToBounds=true
            cellImg.contentMode = .scaleAspectFill
            cellImg.layer.masksToBounds=true
            
            //cell.imgProfilImage.sd_setImage(with: URL(string: UserDetail.profilImage as! String), completed: nil)
            if UserDetail.profilImage != ""
            {
                //cellImg.sd_setImage(with: URL(string: UserDetail.profilImage as! String),)
                cellImg.sd_setImage(with: URL(string: UserDetail.profilImage as! String)) { (image, error, cacheType, url) in
                    if error != nil
                    {
                        cellImg.image = UIImage(named: "default_person")
                    }
                }
            }
            else
            {
                cellImg.image = UIImage(named: "default_person")
            }
            
            //cellImg.image=#imageLiteral(resourceName: "profile-1")
            newView.addSubview(cellImg)
            
            let cellLbl = UILabel(frame: CGRect(x: 40, y: 130, width: 180, height: 21))
            cellLbl.text = arrayMenuOptions[indexPath.row]["title"] //Ad Soyad Buraya Yazılacak
            cellLbl.font=UIFont.systemFont(ofSize: 17)
            cellLbl.textColor=UIColor.white
            newView.addSubview(cellLbl)
            
            let profilLabel = UILabel(frame: CGRect(x: 40, y: 165, width: 120, height: 30))
            profilLabel.text = "Profili Düzenle"
            profilLabel.font = UIFont(name: "ArialHebrew", size: 13)
            profilLabel.textColor = UIColor(red: 174/255, green: 203/255, blue: 238/255, alpha: 1.0)
            newView.addSubview(profilLabel)
    
            
            let cellHeaderLine: UIImageView!
            cellHeaderLine = UIImageView(frame: CGRect(x: 0, y: 218, width: 280, height: 7))
            cellHeaderLine.contentMode = .scaleToFill
            cellHeaderLine.image = #imageLiteral(resourceName: "LeftMenuLine")
            newView.addSubview(cellHeaderLine)
            
            
            cell.addSubview(newView)
            
            
        } else {
            cell.textLabel?.text = arrayMenuOptions[indexPath.row]["title"]
            cell.textLabel?.textColor = UIColor(red: 74/255, green: 137/255, blue: 218/255, alpha: 1.0)
            cell.imageView?.frame = CGRect(x: 40, y: 45, width: 50, height: 50)
            cell.imageView?.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.sidebarDidSelectRow(row: Row(row: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 245
        } else {
            return 60
        }
    }
    
    func setupViews() {
        self.addSubview(myTableView)
        myTableView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        myTableView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        myTableView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        myTableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
    }
    
    let myTableView: UITableView = {
        let table=UITableView()
        table.translatesAutoresizingMaskIntoConstraints=false
        return table
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


