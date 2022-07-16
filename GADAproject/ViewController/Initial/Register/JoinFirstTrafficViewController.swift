//
//  JoinFirstTrafficViewController.swift
//  handycab
//
//  Created by leejungchul on 2021/06/29.
//

import UIKit

class JoinFirstTrafficViewController: UIViewController {
    
    @IBOutlet weak var tvPage: UILabel!
    @IBOutlet weak var tvTitle: UILabel!
    @IBOutlet weak var f_mobil1: UIButton!
    @IBOutlet weak var f_mobil2: UIButton!
    @IBOutlet weak var f_mobil3: UIButton!
    @IBOutlet weak var f_mobil4: UIButton!
    @IBOutlet weak var f_mobil5: UIButton!
    
    var f_mobil: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinFirstTrafficViewController", #function)
    }
    
    @IBAction func f_mobil1Click(_ sender: UIButton) {
        if f_mobil1.isSelected {
            deSelectbtn(button: f_mobil1)
            f_mobil = ""
        } else {
            selectbtn(button: f_mobil1)
            deSelectbtn(button: f_mobil2)
            deSelectbtn(button: f_mobil3)
            deSelectbtn(button: f_mobil4)
            deSelectbtn(button: f_mobil5)
            f_mobil = "1"
        }
        isValidate()
//        DataShare.shared().joindao.hc_type = "1"
    }
    
    @IBAction func f_mobil2Click(_ sender: UIButton) {
        if f_mobil2.isSelected {
            deSelectbtn(button: f_mobil2)
            f_mobil = ""
        } else {
            selectbtn(button: f_mobil2)
            deSelectbtn(button: f_mobil1)
            deSelectbtn(button: f_mobil3)
            deSelectbtn(button: f_mobil4)
            deSelectbtn(button: f_mobil5)
            f_mobil = "2"
        }
        isValidate()
//        DataShare.shared().joindao.hc_type = "2"
    }
    
    @IBAction func f_mobil3Click(_ sender: UIButton) {
        if f_mobil3.isSelected {
            deSelectbtn(button: f_mobil3)
            f_mobil = ""
        } else {
            selectbtn(button: f_mobil3)
            deSelectbtn(button: f_mobil1)
            deSelectbtn(button: f_mobil2)
            deSelectbtn(button: f_mobil4)
            deSelectbtn(button: f_mobil5)
            f_mobil = "3"
        }
        isValidate()
//        DataShare.shared().joindao.hc_type = "3"
    }
    
    @IBAction func f_mobil4Click(_ sender: UIButton) {
        if f_mobil4.isSelected {
            deSelectbtn(button: f_mobil4)
            f_mobil = ""
        } else {
            selectbtn(button: f_mobil4)
            deSelectbtn(button: f_mobil1)
            deSelectbtn(button: f_mobil2)
            deSelectbtn(button: f_mobil3)
            deSelectbtn(button: f_mobil5)
            f_mobil = "4"
        }
        isValidate()
//        DataShare.shared().joindao.hc_type = "4"
    }
    
    @IBAction func f_mobil5Click(_ sender: UIButton) {
        if f_mobil5.isSelected {
            deSelectbtn(button: f_mobil5)
            f_mobil = ""
        } else {
            selectbtn(button: f_mobil5)
            deSelectbtn(button: f_mobil1)
            deSelectbtn(button: f_mobil2)
            deSelectbtn(button: f_mobil3)
            deSelectbtn(button: f_mobil4)
            f_mobil = "5"
        }
        isValidate()
//        DataShare.shared().joindao.hc_type = "4"
    }
 
    
    public func deSelectbtn(button: UIButton) {
        button.isSelected = false
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.pretendard(type: .medium, size: 16)
    }
    
    public func selectbtn(button: UIButton) {
        button.isSelected = true
        button.backgroundColor = .primaryGreen100
        button.titleLabel?.font = UIFont.pretendard(type: .bold, size: 16)
    }
    
    public func isValidate() -> Bool {
        
        if f_mobil1.isSelected || f_mobil2.isSelected || f_mobil3.isSelected || f_mobil4.isSelected || f_mobil5.isSelected {
            NotificationCenter.default.post(name: .joinNoti, object: true)
        } else {
            NotificationCenter.default.post(name: .joinNoti, object: false)
        }
        
        return true
    }
    
    // #
    public func getValue() -> String {
        return f_mobil
    }
}
