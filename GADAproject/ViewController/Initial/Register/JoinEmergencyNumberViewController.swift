//
//  JoinEmergencyNumberViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/07.
//

import UIKit

class JoinEmergencyNumberViewController: UIViewController {

    @IBOutlet weak var emergencyNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
        // Do any additional setup after loading the view.
    }
    
    func initSetting() {
        emergencyNumberTextField.delegate = self
        
        emergencyNumberTextField.layer.borderWidth = 1
        emergencyNumberTextField.layer.borderColor = UIColor.inputDefault?.cgColor
        emergencyNumberTextField.layer.cornerRadius = 2
        emergencyNumberTextField.addLeftPadding()
    }
    
    // #
    public func getValue() -> String {
        let emergencyNumber = emergencyNumberTextField.text ?? ""
        return emergencyNumber
    }

}


extension JoinEmergencyNumberViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("3")
        print(textField.text)
        validateValue()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor.inputActive?.cgColor
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.inputDefault?.cgColor
    }
    
    func validateValue() {
        guard let emergencyNumberCount = emergencyNumberTextField.text?.count else { return }
        
        if emergencyNumberCount < 9 {
            NotificationCenter.default.post(name: .joinNoti, object: false)
        } else {
            NotificationCenter.default.post(name: .joinNoti, object: true)
        }
    }
}

