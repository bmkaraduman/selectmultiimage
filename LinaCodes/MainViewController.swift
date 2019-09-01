//
//  MainViewController.swift
//  Lina
//
//  Created by macbookpro on 17.08.2019.
//  Copyright © 2019 Metin KARADUMAN. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class MainViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sayiList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let seciliRakam = self.sayiList[row]
        self.textBoxDateOft.text = String(seciliRakam)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = String(sayiList[row])
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 26.0)!,NSAttributedString.Key.foregroundColor:UIColor.black])
        
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    let backGroundImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Background_Lena"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let firstPageImage : UIImageView = {
        let imageLogo = UIImageView(image: UIImage(named: "Logo"))
        imageLogo.translatesAutoresizingMaskIntoConstraints = false
        return imageLogo
    }()
    
    let firstPageBelowImageBackground : UIImageView = {
        let imageBelowImage = UIImageView(image: UIImage(named: "FirstPageAlt"))
        imageBelowImage.translatesAutoresizingMaskIntoConstraints = false
        return imageBelowImage
    }()
    
    let textViewLastDate : UIView = {
        let textViewSet = UIView()
        textViewSet.backgroundColor = #colorLiteral(red: 0.8516547084, green: 0.3286998272, blue: 0.6641861796, alpha: 1)
        textViewSet.translatesAutoresizingMaskIntoConstraints = false
        textViewSet.layer.cornerRadius = 10
        
        return textViewSet
    }()
    
    let textViewDateOft : UIView = {
        let textViewSet = UIView()
        textViewSet.backgroundColor = #colorLiteral(red: 1, green: 0.3574400544, blue: 0.5206199288, alpha: 1)
        textViewSet.translatesAutoresizingMaskIntoConstraints = false
        textViewSet.layer.cornerRadius = 10
        return textViewSet
    }()
    let textBoxLastDate : UITextField = {
        let textViewSet = UITextField()
   
        textViewSet.attributedPlaceholder = NSAttributedString(string: "Son Adet Tarihiniz",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.flatWhite(), NSMutableAttributedString.Key.font : UIFont(name: "Helvetica", size: 15.0)!])
        textViewSet.borderStyle = UITextField.BorderStyle.none
        textViewSet.translatesAutoresizingMaskIntoConstraints = false
        return textViewSet
    }()
    
    let textBoxDateOft : UITextField = {
        let textViewSet = UITextField()
        textViewSet.attributedPlaceholder = NSAttributedString(string: "Adet Sıklığınız",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.flatWhite(), NSMutableAttributedString.Key.font : UIFont(name: "Helvetica", size: 15.0)!])
        textViewSet.borderStyle = UITextField.BorderStyle.none
        textViewSet.translatesAutoresizingMaskIntoConstraints = false
        return textViewSet
    }()
    
    let labelSwitch : UILabel = {
        let label_Switch = UILabel()
        label_Switch.textColor = UIColor.flatWhite()
        label_Switch.translatesAutoresizingMaskIntoConstraints = false
        return label_Switch
    }()
    
    let buttonView : UIButton = {
        let button_view = UIButton()
        button_view.translatesAutoresizingMaskIntoConstraints = false
        button_view.setTitle("BAŞLAT", for: .normal)
        button_view.titleLabel?.textColor = UIColor.white
        button_view.layer.cornerRadius = 10
        button_view.backgroundColor = #colorLiteral(red: 0.9671481252, green: 0.3591043651, blue: 0.3811798096, alpha: 1)
        button_view.addTarget(self, action: #selector(btnSearchClick), for: .touchUpInside)
        return button_view
    }()
    
    
    let switchNotificitions : UISwitch =
    {
        let switch_notify = UISwitch()
        switch_notify.translatesAutoresizingMaskIntoConstraints = false
        return switch_notify
    }()
    
    let blog1View : UIView =
    {
        let blog1_View = UIView()
        blog1_View.translatesAutoresizingMaskIntoConstraints = false
        blog1_View.backgroundColor = #colorLiteral(red: 0.8348848224, green: 0.2498204708, blue: 0.6710253358, alpha: 1)
        blog1_View.layer.cornerRadius = 10
        return blog1_View
    }()
    
    let blog2View : UIView =
    {
        let blog2_View = UIView()
        blog2_View.translatesAutoresizingMaskIntoConstraints = false
        blog2_View.backgroundColor = #colorLiteral(red: 0.7142086625, green: 0.3299219608, blue: 0.6381087899, alpha: 1)
        blog2_View.layer.cornerRadius = 10
        return blog2_View
    }()
    
    let blogImageView1 : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Wife"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let blogImageView2 : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Husband"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let buttonBlog1View : UIButton = {
        //let btn =

        let button_view = UIButton()
        button_view.translatesAutoresizingMaskIntoConstraints = false
        button_view.setTitle("Annenin Dikkat Etmesi Gerekenler", for: .normal)
        button_view.titleLabel?.textColor = UIColor.white
        button_view.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button_view.titleLabel?.font =  UIFont(name: "Helvetica", size: 14)
        button_view.addTarget(self, action: #selector(btnBlog1ViewClick), for: .touchUpInside)
        //btnTwoLine?.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;

        return button_view
    }()
    
    let buttonBlog2View : UIButton = {
        let button_view = UIButton()
        button_view.translatesAutoresizingMaskIntoConstraints = false
        button_view.setTitle("Babanın Dikkat Etmesi Gerekenler", for: .normal)
        button_view.titleLabel?.textColor = UIColor.white
        button_view.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button_view.titleLabel?.font =  UIFont(name: "Helvetica", size: 14)
        button_view.addTarget(self, action: #selector(btnBlog2ViewClick), for: .touchUpInside)
        return button_view
    }()
    
    var datePicker = UIDatePicker()
    
    var pickerViewSayilar = UIPickerView()
    var sayiList = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        view.addSubview(backGroundImageView)
        view.addSubview(firstPageImage)
        view.addSubview(textViewLastDate)
        view.addSubview(textViewDateOft)
        view.addSubview(labelSwitch)
        view.addSubview(switchNotificitions)
        view.addSubview(firstPageBelowImageBackground)
        view.addSubview(buttonView)
        view.addSubview(blog1View)
        view.addSubview(blog2View)
        //Default is opened
        switchNotificitions.isOn = true
        
        labelSwitch.text = "Bildirimler Gelsin"
        
        
        //Add Text box view SubView
        textViewLastDate.addSubview(textBoxLastDate)
        textViewDateOft.addSubview(textBoxDateOft)
        
        blog1View.addSubview(blogImageView1)
        blog2View.addSubview(blogImageView2)
        
        blog1View.addSubview(buttonBlog1View)
        blog2View.addSubview(buttonBlog2View)
        
        setupLayout()
        
        self.hideKeyboardWhenTappedAround()
        
        pickerViewSayilar.delegate = self
        pickerViewSayilar.dataSource = self
        
        textBoxDateOft.inputView = pickerViewSayilar
        
        showDatePicker()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupLayout()
    {
        //Setup Background
        backGroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backGroundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        backGroundImageView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        backGroundImageView.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
        //Setup Logo
        firstPageImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        firstPageImage.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 8).isActive = true
        firstPageImage.widthAnchor.constraint(equalToConstant: 218)
        firstPageImage.heightAnchor.constraint(equalToConstant: 318)
        //TextView Last Date
        textViewLastDate.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textViewLastDate.topAnchor.constraint(equalTo: firstPageImage.bottomAnchor, constant: 20).isActive = true
        textViewLastDate.widthAnchor.constraint(equalToConstant: 140).isActive = true
        textViewLastDate.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //Textbox Last Date
        textBoxLastDate.centerXAnchor.constraint(equalTo: textViewLastDate.centerXAnchor).isActive = true
        textBoxLastDate.centerYAnchor.constraint(equalTo: textViewLastDate.centerYAnchor).isActive = true
        textBoxLastDate.widthAnchor.constraint(equalToConstant: 130).isActive = true
        textBoxLastDate.heightAnchor.constraint(equalToConstant: 45).isActive = true
        textBoxLastDate.textAlignment = NSTextAlignment.center
        textBoxLastDate.textColor = UIColor.flatWhite()
        //TextView DateOft
        textViewDateOft.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textViewDateOft.topAnchor.constraint(equalTo: textViewLastDate.bottomAnchor, constant: 10).isActive = true
        textViewDateOft.widthAnchor.constraint(equalToConstant: 140).isActive = true
        textViewDateOft.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //Textbox DateOft
        textBoxDateOft.centerXAnchor.constraint(equalTo: textViewDateOft.centerXAnchor).isActive = true
        textBoxDateOft.centerYAnchor.constraint(equalTo: textViewDateOft.centerYAnchor).isActive = true
        textBoxDateOft.widthAnchor.constraint(equalToConstant: 130).isActive = true
        textBoxDateOft.heightAnchor.constraint(equalToConstant: 45).isActive = true
        textBoxDateOft.textAlignment = NSTextAlignment.center
        textBoxDateOft.textColor = UIColor.flatWhite()
        //Label Switch
        labelSwitch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -50).isActive = true
        labelSwitch.topAnchor.constraint(equalTo: textViewDateOft.bottomAnchor, constant:  30).isActive = true
        labelSwitch.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //Switch
        switchNotificitions.centerXAnchor.constraint(equalTo: labelSwitch.rightAnchor, constant: 30).isActive = true
        switchNotificitions.topAnchor.constraint(equalTo: textViewDateOft.bottomAnchor, constant:  30).isActive = true
        switchNotificitions.heightAnchor.constraint(equalToConstant: 50).isActive = true
        switchNotificitions.widthAnchor.constraint(equalToConstant: 50).isActive = true
        //Başlat Button 163 41
        buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonView.topAnchor.constraint(equalTo: switchNotificitions.bottomAnchor, constant: 20).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        buttonView.widthAnchor.constraint(equalToConstant: 163).isActive = true
        
        //Firstpage Below
        firstPageBelowImageBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        firstPageBelowImageBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        firstPageBelowImageBackground.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        firstPageBelowImageBackground.heightAnchor.constraint(equalToConstant: 168).isActive = true
        
        //Blog1 Viewı
        blog1View.leftAnchor.constraint(equalTo: view.leftAnchor, constant: blog1View.frame.width + 30).isActive = true
        blog1View.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        blog1View.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2.5).isActive = true
        blog1View.heightAnchor.constraint(equalToConstant: firstPageBelowImageBackground.frame.height / 2).isActive = true
        
        //Blog2 Viewı
        blog2View.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -(blog2View.frame.width + 30)).isActive = true
        blog2View.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        blog2View.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2.5).isActive = true
        blog2View.heightAnchor.constraint(equalToConstant: firstPageBelowImageBackground.frame.height / 2).isActive = true
        
        //Blog1 View Image
        blogImageView1.leftAnchor.constraint(equalTo: blog1View.leftAnchor, constant: 5).isActive = true
        blogImageView1.centerYAnchor.constraint(equalTo: blog1View.centerYAnchor).isActive = true
        blogImageView1.widthAnchor.constraint(equalToConstant: 75).isActive = true
        blogImageView1.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        //Blog2 View Image
        blogImageView2.leftAnchor.constraint(equalTo: blog2View.leftAnchor, constant: 5).isActive = true
        blogImageView2.centerYAnchor.constraint(equalTo: blog2View.centerYAnchor).isActive = true
        blogImageView2.widthAnchor.constraint(equalToConstant: 75).isActive = true
        blogImageView2.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        //Blog1 View Text
        buttonBlog1View.rightAnchor.constraint(equalTo: blog1View.rightAnchor, constant: 0).isActive = true
        buttonBlog1View.centerYAnchor.constraint(equalTo: blog1View.centerYAnchor).isActive = true
        buttonBlog1View.widthAnchor.constraint(equalToConstant: 74).isActive = true
        buttonBlog1View.heightAnchor.constraint(equalToConstant: 68).isActive = true
        
        //Blog2 View Text
        buttonBlog2View.rightAnchor.constraint(equalTo: blog2View.rightAnchor, constant: 0).isActive = true
        buttonBlog2View.centerYAnchor.constraint(equalTo: blog2View.centerYAnchor).isActive = true
        buttonBlog2View.widthAnchor.constraint(equalToConstant: 74).isActive = true
        buttonBlog2View.heightAnchor.constraint(equalToConstant: 68).isActive = true
        
        
    }
    
    func showDatePicker()
    {
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        textBoxLastDate.inputAccessoryView = toolbar
        textBoxLastDate.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        textBoxLastDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func btnBlog1ViewClick()
    {
        
    }
    @objc func btnBlog2ViewClick()
    {
        
    }
    
    @objc func btnSearchClick()
    {
        let page = ResultViewController()
        //self.MainNavigationController?.pushViewController(page, animated: true)
        //self.navigationController?.pushViewController(page, animated: false)
        //MainNavigationController.pushViewController(page, animated: true)
        self.navigationController?.pushViewController(page, animated: true)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension UIView
{
    func addConstraintsWithFormat(format : String, views : UIView...)
    {
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerated()
        {
            let key = "v\(index)"
            viewDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
            
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewDictionary))
        
    }
}
