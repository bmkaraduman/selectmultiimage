//
//  ticketListController.swift
//  FirebaseDemo
//
//  Created by macbookpro on 14.04.2019.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import Firebase

class ticketListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblTicketControlList: UITableView!
    var eventList = [TicketControlCL]()
    var eventTicketList = [TicketControlIDCl]()
    
    @IBOutlet weak var viewEtkinlik_Control: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblTicketControlList.delegate = self
        tblTicketControlList.dataSource = self
        
        let databaseReference = Database.database().reference()
        
        _ = databaseReference.child("users").child(UserDetail.id).child("Event").child("Main").observe(.value) { (data) in
            
            //Tüm Eventlar alınır.
            
            var ticketControl = TicketControlCL()
            var ticketControlID = TicketControlIDCl()
            if data.exists()
            {
                let valuesEvents = data.value! as! NSDictionary
                let events = valuesEvents.allKeys
                let dateFormatter = DateFormatter()
                for eventID in events
                {
                    
                    _ = databaseReference.child("users").observe(DataEventType.value, with: { (dataTicket) in
                        
                        if dataTicket.exists()
                        {
                            let valuesTickets = dataTicket.value! as! NSDictionary
                            let valuesTicketIDs = valuesTickets.allKeys
                            let eventIDString = eventID as! String
                            for userID in valuesTicketIDs
                            {
                                let singleUser = valuesTickets[userID] as! NSDictionary
                                
                                if let singleUserTickets = singleUser["tickets"] as! NSDictionary?
                                {
                                    let singleUserTicketIDs = singleUserTickets.allKeys
                                    
                                    for sUserTcktID in singleUserTicketIDs
                                    {
                                        let ticketIDUser = sUserTcktID as! String
                                        let singleTicket = singleUserTickets[sUserTcktID] as! NSDictionary
                                        let eventIDUser = singleTicket["EventID"] as! String
                                        if eventIDUser == eventIDString
                                        {
                                            ticketControlID = TicketControlIDCl()
                                            ticketControlID.EventID = eventIDString
                                            ticketControlID.TicketID = ticketIDUser
                                            self.eventTicketList.append(ticketControlID)
                                        }
                                    }
                                }
                            }
                            ticketControl = TicketControlCL()
                            
                           
                            
                            let valueEvent = valuesEvents[eventIDString] as! NSDictionary
                            let EventAdi = valueEvent["Adi"] as! String
                            let EventResim = valueEvent["Resim1"] as! String
                            let EventSaat = valueEvent["Saat"] as! String
                            let EventTarih = valueEvent["Tarih"] as! String
                            
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                            guard let dateEvent = dateFormatter.date(from: EventTarih) else {
                                fatalError()
                            }
                            
                            dateFormatter.dateFormat = "HH:mm"
                            guard let hourEvent = dateFormatter.date(from: EventSaat) else {
                                fatalError()
                            }
                            
                            
                            ticketControl.ticketList = self.eventTicketList
                            ticketControl.EventDate = dateEvent
                            ticketControl.EventID = eventIDString
                            ticketControl.EventResim = EventResim
                            ticketControl.EventSaat = hourEvent
                            ticketControl.EventAdi = EventAdi
                            self.eventTicketList = [TicketControlIDCl]()
                            let eventVarmi = self.eventList.contains(where: { (ticketCL) -> Bool in
                                ticketCL.EventID == eventIDString
                            })
                            
                            if eventVarmi == false
                            {
                                self.eventList.append(ticketControl)
                            }
                        }
                        
                        if self.eventList.count > 0
                        {
                            self.tblTicketControlList.reloadData()
                            self.viewEtkinlik_Control.isHidden = true
                            self.tblTicketControlList.isHidden = false
                        }
                        else
                        {
                            self.viewEtkinlik_Control.isHidden = false
                            self.tblTicketControlList.isHidden = true
                        }
                    })
                }
            }
            else
            {
                self.viewEtkinlik_Control.isHidden = false
                self.tblTicketControlList.isHidden = true
            }

        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tblTicketControlList.dequeueReusableCell(withIdentifier: "CellTicketDty", for: indexPath) as! ticketListCell
        
        if eventList.count > 0
        {
            cell.imgTicketImage.sd_setImage(with: URL(string: eventList[indexPath.row].EventResim), completed: nil)
            cell.lblTicketName.text = eventList[indexPath.row].EventAdi
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = eventList[indexPath.row].EventDate
            let eventTarih = dateFormatter.string(from: date)
            cell.lblTicketTarih.text = eventTarih
            
            dateFormatter.dateFormat = "HH:mm"
            let saat = eventList[indexPath.row].EventSaat
            let eventSaat = dateFormatter.string(from: saat)
            cell.lblSuresi.text = eventSaat
        }
        
        return cell
        
    }
    
    var ticketEventID = TicketControlCL()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

     ticketEventID.EventID = eventList[indexPath.row].EventID
     ticketEventID.ticketList = eventList[indexPath.row].ticketList
     ticketEventID.EventAdi = eventList[indexPath.row].EventAdi
     
        //Sidebarda(Sol Menünün açıldığı yerde yönlendirmeyi yaptık. Eğer güncelleme ise güncelleme sayfasına gidecek. Değilse Bilet Kontrol Sayfasına gidecek.)
        if biletKontrolMu == false
        {
            performSegue(withIdentifier: "ps_eventGuncelle", sender: nil)
        }
        else
        {
            performSegue(withIdentifier: "ps_ticketList_ticketDetay", sender: nil)
        }
    }
    
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//
//        let idm = String(self.eventList[indexPath.row].EventID)
//        let varMi = eventTicketList.contains { (incEvId) -> Bool in
//            incEvId.EventID == idm
//        }
//        //
//        if varMi == false && biletKontrolMu == false
//        {
//            let delete = deleteAction(at: indexPath)
//            return UISwipeActionsConfiguration(actions: [delete])
//        }
//        else
//        {
//            return nil
//        }
//
//
//    }
    
//    @available(iOS 11.0, *)
//    func deleteAction(at indexPath : IndexPath)->UIContextualAction
//    {
//
//        let action = UIContextualAction(style: .destructive, title: "delete") {
//            (action, view, completion) in
//
//
//            let idm = String(self.eventList[indexPath.row].EventID)
//
//            let databaseReference = Database.database().reference()
//
//            //Ticket var mı bakılır.
//            _ = databaseReference.child("users").child(UserDetail.id).child("Event").child("Main").child(idm).removeValue(completionBlock: { (error, ref) in
//                self.eventList.remove(at: indexPath.row)
//                self.tblTicketControlList.deleteRows(at: [indexPath], with: .automatic)
//                completion(true)
//            })
//
//        }
//        action.backgroundColor = nil
//        action.image = UIImage(named: "trashicon")
//
//        return action
//    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //ps_eventGuncelle
        if segue.identifier == "ps_eventGuncelle"
        {
            let destinationVC = segue.destination as! UploadEvents
            destinationVC.eventID = ticketEventID.EventID
            
           
            
            
            
//            let varMi = eventList.contains { (incEvId) -> Bool in
//                incEvId.EventID == ticketEventID.EventID
//            }
            
            let eventGetir = eventList.first { (tckEvent) -> Bool in
                tckEvent.EventID == ticketEventID.EventID
            }
            
            if (eventGetir?.ticketList.count)! > 0
            {
                destinationVC.ticketVarmi = true
            }
            else
            {
                destinationVC.ticketVarmi = false
            }
            
            
        }
        else
        {
            let destinationVC = segue.destination as! BiletControl
            destinationVC.ticketList = ticketEventID.ticketList
            var eventADi = ticketEventID.EventAdi as! String
            destinationVC.biletAD = eventADi
            destinationVC.eventID = ticketEventID.EventID
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = ticketEventID.EventDate
            let eventTarih = dateFormatter.string(from: date)
            destinationVC.biletTarih = eventTarih
        }
    }
    
    @IBAction func geriClick(_ sender: UIBarButtonItem) {
        
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        
        
    }
    
    }
    
}
