//
//  TaxiInfoViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/15.
//

import UIKit

class TaxiInfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detail1Label: UILabel!
    @IBOutlet weak var detailLine: UIView!
    @IBOutlet weak var detail2Label: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var infoImageView: UIImageView!
    
    @IBOutlet weak var detailViewRightConst: NSLayoutConstraint!
    @IBOutlet weak var detailViewLeftConst: NSLayoutConstraint!
    
    @IBOutlet weak var imageTopConst: NSLayoutConstraint!

    var basicData = TaxiListCall()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingData()
    }
    
    func settingData() {
        print(basicData.name)
        if basicData.name == "" {
            self.detail1Label.frame.size.width = 0
            self.detail1Label.isHidden = true
            self.detailLine.frame.size.width = 0
            self.detailLine.isHidden = true
            self.detailViewLeftConst.constant = 0
            self.detailViewRightConst.constant = 0
        } else {
            self.detail1Label.isHidden = false
            self.detailLine.frame.size.width = 1
            self.detailLine.isHidden = false
            self.detailViewLeftConst.constant = 8
            self.detailViewRightConst.constant = 8
        }
        
        self.titleLabel.text = basicData.call_name
        self.detail1Label.text = basicData.name
        self.detail2Label.text = basicData.operating_name
        self.phoneLabel.text = basicData.phone_number
        
        var image = UIImage()
        var size = 0.0
        
        if basicData.call_name == "서울장애인콜" {
            image = UIImage(named: "text_image")!
            size = 24
        } else {
            image = UIImage(named: "hourglass")!
            size = 64
        }
        
        imageTopConst.constant = size
        infoImageView.image = image
    }
    
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func tapCallBtn(_ sender: Any) {
        UsefulUtils.callTo(phoneNumber: phoneLabel.text ?? "")
    }
}
