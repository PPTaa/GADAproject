//
//  MyNavigationViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/15.
//

import UIKit

class MyNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let test = true
        if DataShare.shared().profileDao.cell_num != "" {
            let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "MyViewController") as! MyViewController
            self.setViewControllers([vc], animated: true)
        } else {
            let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "inputLoginViewController") as! InputLoginViewController
            self.setViewControllers([vc], animated: true)
            
        }
    }
}
