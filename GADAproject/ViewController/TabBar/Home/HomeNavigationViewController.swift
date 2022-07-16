//
//  HomeNavigationViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import UIKit

class HomeNavigationViewController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        // Do any additional setup after loading the view.
    }

}
