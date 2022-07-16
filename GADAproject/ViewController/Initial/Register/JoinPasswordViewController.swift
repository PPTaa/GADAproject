import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class JoinPasswordViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var tvPassword: UITextField!
    @IBOutlet weak var tvAlert: UILabel!
    
    @IBOutlet weak var tvPasswordRe: UITextField!
    @IBOutlet weak var tvAlertRe: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinPasswordViewController", #function)
        initSetting()
        /*
        #if DEBUG
        tvPassword.text = "solter0807"
        #endif
        */
    }
    
    func initSetting() {
        tvPassword.delegate = self
        tvPasswordRe.delegate = self
        
        tvPassword.layer.borderWidth = 1
        tvPassword.layer.cornerRadius = 2
        tvPassword.addLeftPadding()
        tvPassword.layer.borderColor = UIColor.inputDefault?.cgColor
        
        tvPasswordRe.layer.borderWidth = 1
        tvPasswordRe.layer.cornerRadius = 2
        tvPasswordRe.addLeftPadding()
        tvPasswordRe.layer.borderColor = UIColor.inputDefault?.cgColor
        
        tvPasswordReSetting(hidden: true)
        
    }
        
    func tvPasswordReSetting(hidden: Bool) {
        tvAlertRe.text = hidden ? "비밀번호를 한번 더 입력해 주세요." : "비밀번호가 일치하지 않습니다."
        tvAlertRe.textColor = hidden ? UIColor.textPrimary : UIColor.systemError
//        tvAlertReHeightConst.constant = hidden ? 0 : 24
        tvPasswordRe.layer.borderColor = hidden ? UIColor.inputDefault?.cgColor : UIColor.systemError?.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func tapEyeActive(_ sender: UIButton) {
        
        print(sender.isSelected)
        if sender.tag == 0 {
            tvPassword.isSecureTextEntry = sender.isSelected
            tvPassword.keyboardType = .alphabet
        } else {
            tvPasswordRe.isSecureTextEntry = sender.isSelected
            tvPassword.keyboardType = .alphabet
        }
        sender.isSelected = !sender.isSelected
        
    }
    
    
    
    
    
    // #
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateValue()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        validateValue()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateValue()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        validateValue()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validateValue()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        validateValue()
        guard let placeholder = textField.placeholder else { return true }
        
        if placeholder == "비밀번호 확인" {
            tvPasswordReSetting(hidden: true)
        }
        
        textField.layer.borderColor = UIColor.inputActive?.cgColor
        
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderColor = UIColor.inputDefault?.cgColor
        validateValue()
    }
    
    private func validateValue() {
        if tvPassword.text!.count >= 4 && tvPassword.text!.count <= 16 && tvPasswordRe.text!.count >= 4 && tvPasswordRe.text!.count <= 16  {
            NotificationCenter.default.post(name: .joinNoti, object: true)
        } else {
            NotificationCenter.default.post(name: .joinNoti, object: false)
        }
    }
    
    // #
    public func getValue() -> [String] {
        return [tvPassword.text!, tvPasswordRe.text!]
    }
    
    // 구현 필요
    public func isValidate() -> Bool {
    
        /*
        "text_join_11" = "가입이 된 번호입니다.";
        "text_join_12" = "휴대폰번호를 정확히 입력해주세요.";
        "text_join_13" = "8글자 이상 영문/숫자를 사용해주세요.";
        "text_join_14" = "가입이 된 번호입니다.";
        */
        
//        if let p = tvPassword.text {
//            print("ValidateUtils.shared().checkPassword(str: p) : \(ValidateUtils.shared().checkPassword(str: p))")
//            if !ValidateUtils.shared().checkPassword(str: p) {
//                tvPassword.layer.borderColor = UIColor(named: "color-error")?.cgColor
//                tvAlert.textColor = UIColor(named: "color-error") ?? .clear
//                
//                tvPasswordRe.layer.borderColor = UIColor(named: "color-error")?.cgColor
//                tvAlertRe.textColor = UIColor(named: "color-error") ?? .clear
//                return false
//            }
//        }
        
//        tvAlert.isHidden = true
        return true
    }
}
