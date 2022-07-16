//
//  JoinMoreTermsViewController.swift
//  GADA
//
//  Created by leejungchul on 2022/07/05.
//

import UIKit

class JoinMoreTermsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    var termTitle: String?
    var termSubTitle: String?
    var termDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = termTitle ?? ""
        subTitleLabel.text = "HANDYCAB \(termSubTitle ?? "") 다음과 같은 내용을 담고 있습니다."
        descriptionTextView.text = termDescription ?? ""

        // Do any additional setup after loading the view.
    }
    @IBAction func tapDismissBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
