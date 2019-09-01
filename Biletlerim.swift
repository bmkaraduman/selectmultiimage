//
//  Biletlerim.swift
//  FirebaseDemo
//
//  Created by macbookpro on 2.04.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

class Biletlerim: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tblBiletlerim: UITableView!
    
    @IBOutlet weak var tblTamamlanmisBiletler: UITableView!
    
    
    var kalanGun = String()
    var kalanSaat = String()
    var kalanDakika = String()
    
    @IBOutlet weak var viewBiletOk: UIView!
    @IBOutlet weak var viewBiletOkMesaj: UILabel!
    @IBOutlet weak var sgmt_Ctrl: UISegmentedControl!
    
    var ticketArray = [TicketCL]()
    var ticketTamamlanmisArray = [TicketCL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblBiletlerim.isHidden = true
        tblTamamlanmisBiletler.isHidden = true
        viewBiletOk.isHidden = true
        
        tblBiletlerim.delegate = self
        tblBiletlerim.dataSource = self
        
        tblTamamlanmisBiletler.delegate = self
        tblTamamlanmisBiletler.dataSource = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        getData()

    }
    
    
    
    func getData() {
        let databaseReference = Database.database().reference()
        let myTickets = databaseReference.child("users").child(UserDetail.id).child("tickets").observe(.value) { (data) in
            if data.exists()
            {
                let ticketsDict = data.value! as! NSDictionary
                let ticketIDs = ticketsDict.allKeys
                
                for ticketId in ticketIDs
                {
                    var ticketCl = TicketCL()
                    let ticket = ticketsDict[ticketId] as! NSDictionary
                    let eventID = ticket["EventID"] as! String
                    let EventUserID = ticket["EventUserID"] as! String
                    var tamamlanmis = Bool()
                    let event = databaseReference.child("users").child(EventUserID).child("Event").child("Main").child(eventID).observe(.value, with: { (dataEvent) in
                        if dataEvent.exists()
                        {
                            //Addres bilgileri alınır.
                            let eventDetay = dataEvent.value! as! NSDictionary
                            let EventAdi = eventDetay["Adi"] as! String
                            let EventIl = eventDetay["IL"] as! String
                            let EventIlce = eventDetay["Ilce"] as! String
                            let EventTarih = eventDetay["Tarih"] as! String
                            let EventSaat = eventDetay["Saat"] as! String
                            let EventSuresizmi = eventDetay["Suresiz"] as! String
                            let Resim1 = eventDetay["Resim1"] as! String
                            
                            let eventUserIDProfile = databaseReference.child("users").child(EventUserID).child("profile").child(EventUserID).observe(.value, with: { (dataEventUser) in
                                
                                if dataEventUser.exists()
                                {
                                    let eventUserProfile = dataEventUser.value! as! NSDictionary
                                    let EventOwnerAdSoyad = eventUserProfile["AdSoyad"] as! String
                                    let Isletmemi = eventUserProfile["Isletmemi"] as! String
                                    let EventOwnerprofilResim = eventUserProfile["ProfilResim"] as! String
                                    
                                    ticketCl.TicketID = ticketId as! String
                                    ticketCl.EventID = eventID
                                    ticketCl.EventUserID = EventUserID
                                    ticketCl.EventAdi = EventAdi
                                    ticketCl.Il = EventIl
                                    ticketCl.Ilce = EventIlce
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd/MM/yyyy"
                                    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                                    guard let dateEvent = dateFormatter.date(from: EventTarih) else {
                                        fatalError()
                                    }
                                    
                                    ticketCl.EventDate = dateEvent
                                    
                                    dateFormatter.dateFormat = "HH:mm"
                                    guard let hourEvent = dateFormatter.date(from: EventSaat) else {
                                        fatalError()
                                    }
                                    
                                    
                                    let dateMerge = EventTarih + " " + EventSaat
                                    
                                    (ticketCl.kalanGun, ticketCl.kalanSaat, ticketCl.kalanDakika, tamamlanmis) = self.calculateTimeDifference(from: dateMerge)
                                    
                                    ticketCl.EventSaat = hourEvent
                                    ticketCl.Suresizmi = Bool(EventSuresizmi)!
                                    ticketCl.KullaniciAdi = EventOwnerAdSoyad
                                    ticketCl.Isletmemi = Bool(Isletmemi)!
                                    ticketCl.EventResim = Resim1
                                    ticketCl.ProfilResim = EventOwnerprofilResim
                                    
                                    var ticketBul1 = self.ticketTamamlanmisArray.contains(where: { (ticketID) -> Bool in
                                        ticketID.TicketID == ticketCl.TicketID
                                    })
                                    
                                    var ticketBul2 = self.ticketArray.contains(where: { (ticketID) -> Bool in
                                        ticketID.TicketID == ticketCl.TicketID
                                    })
                                    
                                    
                                    if ticketBul1 == false && ticketBul2 == false
                                    {
                                        if tamamlanmis == true
                                        {
                                            self.ticketTamamlanmisArray.append(ticketCl)
                                        }
                                        else
                                        {
                                            self.ticketArray.append(ticketCl)
                                        }
                                    }
                                    
                                    
                                }
                                if self.ticketArray.count > 0
                                {
                                    self.tblBiletlerim.reloadData()
                                    self.viewBiletOk.isHidden = true
                                    self.tblBiletlerim.isHidden = false
                                }
                                else
                                {
                                    self.viewBiletOk.isHidden = false
                                    self.tblBiletlerim.isHidden = true
                                    self.viewBiletOkMesaj.text = "Aktif Bir Biletiniz Bulunmuyor"
                                }
                                
                                if self.ticketTamamlanmisArray.count > 0
                                {
                                    self.tblTamamlanmisBiletler.reloadData()
                                    self.tblTamamlanmisBiletler.isHidden = true
                                }
                            }
                            )
                        }
                    })
                }
             
            }
            else
            {
                self.viewBiletOk.isHidden = false
                self.tblTamamlanmisBiletler.isHidden = true
                self.tblBiletlerim.isHidden = true
                self.viewBiletOkMesaj.text = "Yaklaşmakta Olan Biletiniz Bulunmuyor"
            }
        }
    }
    
    
    @IBAction func sgmntControl_Changed(_ sender: UISegmentedControl) {
        
        let getIndex = sgmt_Ctrl.selectedSegmentIndex
        
        switch getIndex {
        case 0:
            //Mevcut etkinlikler getirilecek. Her seferinde de load etmeye gerek yok.
            
            if self.ticketArray.count > 0
            {
                tblBiletlerim.isHidden = false
                tblTamamlanmisBiletler.isHidden = true
                self.viewBiletOk.isHidden = true
                self.tblBiletlerim.reloadData()
            }
            else
            {
                self.viewBiletOk.isHidden = false
                self.tblTamamlanmisBiletler.isHidden = true
                self.tblBiletlerim.isHidden = true
                self.viewBiletOkMesaj.text = "Yaklaşmakta Olan Biletiniz Bulunmuyor"
            }
            
        case 1:
            //Geçmiş etkinlikler getirilecek.
            
            
            if self.ticketTamamlanmisArray.count > 0 {
                
                tblBiletlerim.isHidden = true
                tblTamamlanmisBiletler.isHidden = false
                self.viewBiletOk.isHidden = true
            }
            else
            {
                self.viewBiletOk.isHidden = false
                self.tblTamamlanmisBiletler.isHidden = true
                self.tblBiletlerim.isHidden = true
                self.viewBiletOkMesaj.text = "Tamamlanmış Biletiniz Bulunmuyor"
            }
            
            self.tblTamamlanmisBiletler.reloadData()
        default:
            print("Diğer Durumlar")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblBiletlerim
        {
            return ticketArray.count
        }
        else
        {
            return ticketTamamlanmisArray.count
        }
            
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //CellTicketNo
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        if tableView == self.tblBiletlerim
        {
            let cell = tblBiletlerim.dequeueReusableCell(withIdentifier: "CellTicket", for: indexPath) as! BiletlerimCell

            if ticketArray.count > 0
            {
                cell.imgEvent.sd_setImage(with: URL(string: ticketArray[indexPath.row].EventResim), completed: nil)
                cell.imgUser.sd_setImage(with: URL(string: ticketArray[indexPath.row].ProfilResim), completed: nil)
            
                let date = ticketArray[indexPath.row].EventDate
                let cellDate = dateFormatter.string(from: date)
                
                
                cell.lblEventDate.text = cellDate
                cell.lblEventYer.text = String(ticketArray[indexPath.row].Il) + "/" + String(ticketArray[indexPath.row].Ilce)
                cell.lblUserName.text = ticketArray[indexPath.row].KullaniciAdi as! String
                cell.lblEventName.text = ticketArray[indexPath.row].EventAdi as! String
                
                cell.imgUser.layer.cornerRadius = cell.imgUser.frame.height / 2
                cell.imgUser.layer.masksToBounds = true
                cell.imgUser.contentMode = .scaleToFill
                
                cell.view_ticket_detay.layer.cornerRadius = 10
                cell.imgEvent.layer.cornerRadius = 10
                
                cell.lblGun.text = ticketArray[indexPath.row].kalanGun
                cell.lblSaat.text = ticketArray[indexPath.row].kalanSaat
                cell.lblDakika.text = ticketArray[indexPath.row].kalanDakika
            }
            
            return cell
        }
        else
        {
            
            let cell = tblTamamlanmisBiletler.dequeueReusableCell(withIdentifier: "CellTicketOK", for: indexPath) as! BiletlerimCell
            
            if ticketTamamlanmisArray.count > 0
            {
                cell.imgEvent.sd_setImage(with: URL(string: ticketTamamlanmisArray[indexPath.row].EventResim), completed: nil)
                cell.imgUser.sd_setImage(with: URL(string: ticketTamamlanmisArray[indexPath.row].ProfilResim), completed: nil)
                
                let date = ticketTamamlanmisArray[indexPath.row].EventDate
                let cellDate = dateFormatter.string(from: date)
                
                cell.lblEventDate.text = cellDate
                cell.lblEventYer.text = String(ticketTamamlanmisArray[indexPath.row].Il) + "/" + String(ticketTamamlanmisArray[indexPath.row].Ilce)
                cell.lblUserName.text = ticketTamamlanmisArray[indexPath.row].KullaniciAdi as! String
                cell.lblEventName.text = ticketTamamlanmisArray[indexPath.row].EventAdi as! String
                
                cell.imgUser.layer.cornerRadius = cell.imgUser.frame.height / 2
                cell.imgUser.layer.masksToBounds = true
                cell.imgUser.contentMode = .scaleToFill
                
                cell.view_ticket_detay.layer.cornerRadius = 10
                cell.imgEvent.layer.cornerRadius = 10
                
                cell.lblGun.text = ticketTamamlanmisArray[indexPath.row].kalanGun
                cell.lblSaat.text = ticketTamamlanmisArray[indexPath.row].kalanSaat
                cell.lblDakika.text = ticketTamamlanmisArray[indexPath.row].kalanDakika
            }
            return cell
        }
    }
    
    
    var ticketSelectCl = TicketCL()
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tblBiletlerim
        {
            ticketSelectCl.EventUserID = ticketArray[indexPath.row].EventUserID
            ticketSelectCl.EventID = ticketArray[indexPath.row].EventID
            ticketSelectCl.TicketID = ticketArray[indexPath.row].TicketID
        }
        else
        {
            ticketSelectCl.EventUserID = ticketTamamlanmisArray[indexPath.row].EventUserID
            ticketSelectCl.EventID = ticketTamamlanmisArray[indexPath.row].EventID
            ticketSelectCl.TicketID = ticketTamamlanmisArray[indexPath.row].TicketID
        }
        
        
        performSegue(withIdentifier: "ps_mytickets_qr", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! QRCodeTicket
        destinationVC.eventUserId = ticketSelectCl.EventUserID
        destinationVC.ticketNumber = ticketSelectCl.TicketID
        
    }
    
    func calculateTimeDifference(from dateTime1: String) -> (String, String, String, Bool) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let date = Date()
        let currentDate = dateFormatter.string(from: date)
        

        let dateAsString = dateTime1
        let date1 = dateFormatter.date(from: dateAsString)!
        
        //let dateAsString2 = dateTime2
        let date2 = dateFormatter.date(from: currentDate)!
        
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]
        let difference = (Calendar.current as NSCalendar).components(components, from: date2, to: date1, options: [])
        
        let gun = String(difference.day as! Int)
        let hour = String(difference.hour as! Int)
        let minute = String(difference.minute as! Int)
        
        if date2 > date1
        {
            return (gun, hour, minute, true)
        }
        else
        {
            return (gun, hour, minute, false)
        }
        
        
    }
}
