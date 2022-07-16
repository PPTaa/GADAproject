//
//  SubwayNavigationViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit

class SubwayNavigationViewController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        // Do any additional setup after loading the view.
    }

}
