import UIKit
import SwiftyJSON
import SwiftyUserDefaults


/**
 - note:
 */
class JoinNickNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tvPage:UILabel!
    @IBOutlet weak var tvTitle:UILabel!
    @IBOutlet weak var tvName:UITextField!
    @IBOutlet weak var tvAlert:UILabel!
    
    
    public var failClick: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinNickNameViewController", #function)
        
        tvName.delegate = self
        tvAlert.isHidden = false
        
        tvName.layer.borderWidth = 1
        tvName.layer.cornerRadius = 5
        tvName.addLeftPadding()
        tvName.layer.borderColor = UIColor(named: "color-gray-4")?.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // #
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        let previousText:NSString = textField.text! as NSString
        let currentText = previousText.replacingCharacters(in: range, with: string)
        validateValue()
        return true
    }
    
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
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        validateValue()
    }
    
    private func validateValue() {
    
        tvName.layer.borderColor = UIColor(named: "color-gray-4")?.cgColor
        tvAlert.text = "최대 16자 국문/영문/숫자/특수문자 사용 가능"
        tvAlert.textColor = .black
        
    }
    
    
    // #
    public func getValue() -> String {
        
        return tvName.text!
    }
    
    // 닉네임 중복확인 API
    public func isValidate(nickName:String, callBack: @escaping (_ bool:Bool) -> ()) -> Void {
        // 닉네임 중복확인 API 필요
        print("JoinNickNameViewController : \(nickName)")
//        if !Reachability.isConnectedToNetwork() {
//            toast(message: "network_error".localized())
//            return
//        }
        var params:[String:Any] = [
            "name" : nickName
        ]
        
        let path:String = CommonRequest.shared.getServer() + BaseConst.NET_MEMBER_NICKNAME_CHECK
        
        CommonRequest.shared.request(path, params: params as! [String : Any]) {
            
            (_ result: JSON) in
            
            SLoader.hide()
            
            if !result.isEmpty {
                
                print(result)
                print(result["code"].intValue)
                
                // # 등록 성공 시
                if result["code"].intValue == 200 {
                    DispatchQueue.main.async { [self] in
                        callBack(true)
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        tvName.layer.borderColor = UIColor(named: "color-error")?.cgColor
                        tvAlert.text = "중복된 닉네임입니다."
                        tvAlert.textColor = UIColor(named: "color-error") ?? .clear
                        callBack(false)
                    }
                }
            } else {
                callBack(false)
            }
        }
        return
    }
}
