//
//  Etkinlik_Class.swift
//  FirebaseDemo
//
//  Created by macbookpro on 17.12.2018.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import Foundation

class MainEtkinlik {

        var etkinlikAdi: String
        var etkinlikTarihi: String
        var EtkinlikSaati: String //Saat olarak alınacak
        var etkinlikAciklama : String
        var etkinlikSuresiz : String
        var etkinlikAdresi : String
        var etkinlikUcretsiz : String
        var etkinlikKategorisi : String
        var etkinlikResimi : String
        var etkinlikResimi2 : String
        var etkinlikResimi3 : String
        var etkinlikResim4 : String
        var EtkinlikKonum : String
        var EtkinlikUcret : String
        var EtkinlikID : String
        var profilResim : String
        var userName : String
        var begeniSayisi : String
        var benVarmiyim : Bool
        var commentCount : Int
        var profilIsletmemi : Bool
    
    var EtkinlikUserID : String
    
    init(etkinlik_Adi: String, etkinlik_Tarihi: String, Etkinlik_Saati: String, etkinlik_Aciklama: String, etkinlik_Suresiz : String, etkinlik_Adresi: String, etkinlik_Ucretsiz : String, etkinlik_Kategorisi : String, etkinlik_resmi : String,etkinlik_resmi2 : String,etkinlik_resmi3 : String,etkinlik_resmi4 : String, etkinlik_konum : String, etkinlik_ucret : String, etkinlik_UserID : String, etkinlik_id : String, profil_Resim : String, user_Name : String, begeni_Sayisi : String, ben_Varmiyim : Bool, comment_Count : Int, profil_Isletmemi : Bool) {
    
            self.etkinlikAciklama = etkinlik_Aciklama
            self.etkinlikAdi = etkinlik_Adi
            self.etkinlikAdresi = etkinlik_Adresi
            self.EtkinlikKonum = etkinlik_konum
            self.etkinlikTarihi = etkinlik_Tarihi
            self.EtkinlikSaati = Etkinlik_Saati
            self.etkinlikSuresiz = etkinlik_Suresiz
            self.etkinlikUcretsiz = etkinlik_Ucretsiz
            self.etkinlikKategorisi = etkinlik_Kategorisi
            self.etkinlikResimi = etkinlik_resmi
            self.etkinlikResimi2 = etkinlik_resmi2
            self.etkinlikResimi3 = etkinlik_resmi3
            self.etkinlikResim4 = etkinlik_resmi4
            self.EtkinlikUcret = etkinlik_ucret
            self.EtkinlikUserID = etkinlik_UserID
            self.EtkinlikID = etkinlik_id
            self.profilResim = profil_Resim
            self.userName = user_Name
            self.begeniSayisi = begeni_Sayisi
            self.benVarmiyim = ben_Varmiyim
            self.commentCount = comment_Count
            self.profilIsletmemi = profil_Isletmemi
        }
}
