//
//  MyViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit

class MyViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    
    
//    let myData = DataShare.shared().profileDao

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSetting()
    }
    func dataSetting() {
        let myData = DataShare.shared().profileDao
        print(myData)
        UsefulUtils.roundingCorner(view: self.profileImageView)
        self.nickNameLabel.text = myData?.name
        self.phoneNumberLabel.text = myData?.cell_num
    }
    

}
