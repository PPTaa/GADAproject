//
//  TaxiSearchViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import UIKit

class TaxiSearchViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchTextField.layer.borderColor = UIColor.inputDefault?.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 2
        searchTextField.addLeftPadding()
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
