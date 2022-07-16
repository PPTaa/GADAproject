import UIKit
import SwiftyJSON
import SwiftyUserDefaults
import FirebaseAuth


/**
 - note: 
 */
class JoinPhoneViewController: UIViewController, UITextFieldDelegate {
    
    public var failClick: (() -> ())?
    
    
    @IBOutlet weak var tvPage:UILabel!
    @IBOutlet weak var tvTitle:UILabel!
    
    @IBOutlet weak var tvPhone: UITextField!
    @IBOutlet weak var tvPhoneLabel:UILabel!
    @IBOutlet weak var tvPhoneLabelHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var tvVerificationCode: UITextField!
    @IBOutlet weak var tvVerificationAlert: UILabel!
    @IBOutlet weak var tvVerificationAlertHeightConst: NSLayoutConstraint!
    
    
    private var lastTvPhoneCount: Int = 0
    
    public var verifyID: String?
    public var authVerification: Bool = false
    
    private var joinViewController: JoinViewController!
    private var confirmDialog:ConfirmPopupView!
    private var alertDialog:AlertPopupView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinPhoneViewController", #function)
        
        initSetting()
        
        // #
        confirmDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "ConfirmPopupView") as! ConfirmPopupView)
        confirmDialog.modalTransitionStyle = .crossDissolve
        confirmDialog.modalPresentationStyle = .overCurrentContext
        
        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
        alertDialog.modalTransitionStyle = .crossDissolve
        alertDialog.modalPresentationStyle = .overCurrentContext
                
//        tvPhone.attributedPlaceholder = NSAttributedString(string: "text_join_16".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 51/255, green: 51/255, blue: 51/255, alpha: 0.5)])
                        
        /*
        #if DEBUG
        tvPhone.text = "01071813390"
        #endif
        */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("JoinPhoneViewController", #function)
        authVerification = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initSetting() {
        tvVerificationAlert
        tvVerificationAlert.isHidden = true
        tvVerificationCode.isHidden = true
        tvPhoneLabel.isHidden = true
        
        tvPhone.delegate = self
        tvVerificationCode.delegate = self
        
        tvPhone.layer.borderWidth = 1
        tvPhone.layer.cornerRadius = 2
        tvPhone.addLeftPadding()
        tvPhone.layer.borderColor = UIColor.inputDefault?.cgColor
        
        tvVerificationCode.layer.borderWidth = 1
        tvVerificationCode.layer.cornerRadius = 2
        tvVerificationCode.addLeftPadding()
        tvVerificationCode.layer.borderColor = UIColor.inputDefault?.cgColor
        tvPhoneSetting(hidden: true)
        tvVerificationSetting(hidden: true)
    }
    
    func tvPhoneSetting(hidden: Bool) {
        tvPhoneLabel.isHidden = hidden
        tvPhoneLabelHeightConst.constant = hidden ? 0 : 24
        tvPhone.layer.borderColor = hidden ? UIColor.inputDefault?.cgColor : UIColor.systemError?.cgColor
    }
    
    func tvVerificationSetting(hidden: Bool) {
        tvVerificationAlert.isHidden = hidden
        tvVerificationAlertHeightConst.constant = hidden ? 0 : 24
        tvVerificationCode.layer.borderColor = hidden ? UIColor.inputDefault?.cgColor : UIColor.systemError?.cgColor
    }
    
    
    // #
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("0")
        validateValue()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("2")
        validateValue()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("3")
        validateValue()
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("5")
        guard let placeholder = textField.placeholder else { return true }
        if placeholder == "휴대폰 번호" {
            tvPhoneSetting(hidden: true)
        }
        
        if placeholder == "인증번호 입력" {
            tvVerificationSetting(hidden: true)
        }
        
        textField.layer.borderColor = UIColor.inputActive?.cgColor
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("6")
        textField.layer.borderColor = UIColor.inputDefault?.cgColor
    }
    
    private func validateValue() {
        tvPhoneLabel.isHidden = true
        let nowTvPhoneCount = tvPhone.text?.count ?? 0
        if nowTvPhoneCount < 9 {
            NotificationCenter.default.post(name: .joinNoti, object: false)
        } else {
            NotificationCenter.default.post(name: .joinNoti, object: true)
        }
    }
    
    // #
    public func getValue() -> String {
        
        return tvPhone.text!
    }
    
    public func firebaseAuth(callBack: @escaping (_ bool:Bool)->()) -> Void {
        
        Auth.auth().languageCode = "ko"
        
        let phoneNumber = tvPhone.text!
        let tempNumberArray = Array(phoneNumber)
        let tempNumber = String(tempNumberArray[1..<tempNumberArray.count])
        let newphone = "+82\(tempNumber)"
        print(phoneNumber)
        print(newphone)
        
        self.requestCheckPhone(phone: phoneNumber) { (bool) in
            // bool : DB의 전화번호가 있는지 없는지 확인
            // 있으면 false , 없으면 true
            if bool {
                self.tvPhoneLabel.isHidden = true
                PhoneAuthProvider.provider().verifyPhoneNumber(newphone, uiDelegate: nil) { verificationID, error in
                    print("verificationID : \(verificationID)")
                    if let error = error {
                        print("error : \(error.localizedDescription)")
                        self.tvPhoneSetting(hidden: false)
                        self.tvPhoneLabel.text = "text_join_12".localized()
                        callBack(false)
                        return
                    } else {
                        print("verificationID OK")
                        self.tvPhoneSetting(hidden: true)
                        self.verifyID = verificationID ?? ""
                        callBack(true)
                        self.tvVerificationCode.isHidden = false
                    }
                }
            } else {
                self.tvPhoneSetting(hidden: false)
                self.tvPhoneLabel.text = "text_join_11".localized()
            }
        }
    }
    
    // #
    public func isValidate(callBack: @escaping (_ bool:Bool)->()) -> Void {
    
        if verifyID == nil {
            tvPhoneLabel.text = "인증해주세요"
            tvPhoneLabel.isHidden = false
            tvPhone.layer.borderColor = UIColor.systemError?.cgColor
            print("인증 시도 안함 ")
            callBack(false)
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verifyID ?? "", verificationCode: tvVerificationCode.text ?? "")

        Auth.auth().signIn(with: credential) { (success, error) in
            if error == nil {
                print( success ?? "")
                print("User Sign In")
                callBack(true)
            } else {
                print("인증번호 툴림")
                self.tvVerificationSetting(hidden: false)
                print(error.debugDescription)
                callBack(false)
                return
            }
        }
//        callBack(true)
    }
    
    
    private func requestCheckPhone(phone:String, callBack:@escaping (_ bool:Bool)->()) -> Void {
        
//        if !Reachability.isConnectedToNetwork() {
//
//            toast(message: "network_error".localized())
//            return
//        }
        
        SLoader.showLoading()
        
        var params:[String:Any] = [
            "cell_num" : phone
        ]
        
        let path:String = CommonRequest.shared.getServer() + BaseConst.NET_MEMBER_CHECK
        
        CommonRequest.shared.request(path, params: params as! [String : String]) {
            
            (_ result: JSON) in
            
            SLoader.hide()
            
            if !result.isEmpty {
                               
                // # 등록 성공 시
                if result["code"].intValue == 200 {
                    callBack(true)
                } else {
                    callBack(false)
                }
            }
        }
    }
}
