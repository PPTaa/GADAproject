//
//  InputLoginViewController.swift
//  GADA
//
//  Created by leejungchul on 2022/07/05.
//

import UIKit
import SwiftyJSON
import SwiftyUserDefaults
import RealmSwift
import Alamofire

class InputLoginViewController: UIViewController {
    
    @IBOutlet weak var tvPhone: UITextField!
    @IBOutlet weak var tvPhoneLabel: UILabel!
    @IBOutlet weak var tvPhoneLabelHeightConst:  NSLayoutConstraint!
    
    @IBOutlet weak var tvPassword: UITextField!
    @IBOutlet weak var tvPasswordLabel: UILabel!
    @IBOutlet weak var tvPasswordLabelHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    
    
    private var alertDialog:AlertPopupView!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidLoad")
        basicSetting()
        
        tvPhone.text = Defaults.defaults.string(forKey: BaseConst.SPC_USER_ID)
        tvPassword.text = Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD)
        
        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
        alertDialog.modalTransitionStyle = .crossDissolve
        alertDialog.modalPresentationStyle = .overCurrentContext
        
        //키보드 노티피케이션으로 감지
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        validateValue()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    func basicSetting() {
        tvPhone.delegate = self
        tvPassword.delegate = self
        
        tvPhone.layer.borderWidth = 1
        tvPhone.layer.cornerRadius = 2
        tvPhone.addLeftPadding()
        tvPhone.layer.borderColor = UIColor.inputDefault?.cgColor
    
        
        tvPassword.layer.borderWidth = 1
        tvPassword.layer.cornerRadius = 2
        tvPassword.addLeftPadding()
        tvPassword.layer.borderColor = UIColor.inputDefault?.cgColor
        
        tvPhoneSetting(hidden: true)
        tvPasswordSetting(hidden: true)
        
        btnRegister.layer.borderWidth = 1
        btnRegister.layer.borderColor = UIColor.buttonActive?.cgColor
    }
    
    func tvPhoneSetting(hidden: Bool) {
        tvPhoneLabel.isHidden = hidden
        tvPhoneLabelHeightConst.constant = hidden ? 0 : 24
        tvPhone.layer.borderColor = hidden ? UIColor.inputDefault?.cgColor : UIColor.systemError?.cgColor
    }
    
    func tvPasswordSetting(hidden: Bool) {
        tvPasswordLabel.isHidden = hidden
        tvPasswordLabelHeightConst.constant = hidden ? 0 : 24
        tvPassword.layer.borderColor = hidden ? UIColor.inputDefault?.cgColor : UIColor.systemError?.cgColor
    }
    
    // 변수 검사
    private func validateValue() {
        print("validate")
    
    }

    @IBAction func disMissPage(_ sender: Any) {
        print("click Dismiss")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginConfirm(_ sender: Any) {
        let id = tvPhone.text!
        let pwd = tvPassword.text!
        
        if id.stringTrim().count == 0 || pwd.stringTrim().count == 0 {
            
            
            if id.stringTrim().count == 0 {
                
//                toast(message: "text_login_9".localized())
                return
            }
            
            if pwd.stringTrim().count == 0 {
                
//                toast(message: "text_login_10".localized())
                return
            }
            
            return
        }
        
        requestLogin(id: id, pwd: pwd)
    }
    
    
    @IBAction func tapRegister(_ sender: Any) {
        let vc = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "JoinViewController") as! JoinViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapFindPassword(_ sender: Any) {
        tvPhoneSetting(hidden: false)
        tvPasswordSetting(hidden: true)
        
    }
    
    @IBAction func tapServiceCenter(_ sender: Any) {
        tvPhoneSetting(hidden: true)
        tvPasswordSetting(hidden: false)
        
    }
    
    // # 로그인
    private func requestLogin(id:String, pwd:String) -> Void {
        print("requestLogin+++++++++++ \(id) \(pwd)")
        SLoader.showLoading()
        
        var params:[String:Any] = [
            "cell_num" : id,
            "passwd" : pwd
        ]
        
        let path:String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_MEMBER_LOGIN
        
        CommonRequest.shared.request(path, params: params as! [String : String]) {
            
            (_ result: JSON) in
            
            SLoader.hide()
            
            if !result.isEmpty {

                print("result['code'] : ", result["code"])
                
                // # 등록 성공 시
                if result["code"].intValue == 200 {
                    
                    Defaults.defaults.setValue(true, forKey: BaseConst.SPC_USER_LOGIN)
                    Defaults.defaults.setValue(self.tvPhone.text!, forKey: BaseConst.SPC_USER_ID)
                    Defaults.defaults.setValue(self.tvPassword.text!, forKey: BaseConst.SPC_USER_PWD)
                    
                    DispatchQueue.main.async {
                        [self] in
                        requestProfile()
                    }
                } else if result["code"].intValue == 201 {
                    // 가입한 회원 정보가 없음
                    self.tvPhoneSetting(hidden: false)
                } else if result["code"].intValue == 202 {
                    // 비밀번호 틀림
                    self.tvPasswordSetting(hidden: false)
                }
                
                else {
                    
                    DispatchQueue.main.async {
                        [self] in
                        // 가입한 회원 정보가 없음
                        tvPhoneSetting(hidden: false)
                        
                        
                        if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
                        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
                        alertDialog.modalTransitionStyle = .crossDissolve
                        alertDialog.modalPresentationStyle = .overCurrentContext
                        
                        alertDialog.descString = "text_findpw_11".localized()
                        alertDialog.confirmString = "confirm".localized()
                        alertDialog.confirmClick = { () -> () in  }
                        present(alertDialog, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    private func requestProfile() -> Void {
        print("requestProfile+++++++++++")
        
        SLoader.showLoading()
        
        let params:[String:Any] = [
            "cell_num" : Defaults.defaults.string(forKey: BaseConst.SPC_USER_ID),
            "passwd" : Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD)
        ]
        
        
        let path:String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_MEMBER_INFO
        
        CommonRequest.shared.requestJSON(path, params: params as! [String : String]) {
            
            (_ result: JSON) in
            
            SLoader.hide()
            print("--------------------- requestProfile 결과 \(result)")
            
            if !result.isEmpty {
                
//                console.i(result)
                
                // # 예외 처리
                if "0" == result["code"].stringValue {
                    
                    DispatchQueue.main.async {
                        [self] in
                        // 비밀번호 불일치
                        tvPasswordSetting(hidden: false)
                        
                        if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
                        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
                        alertDialog.modalTransitionStyle = .crossDissolve
                        alertDialog.modalPresentationStyle = .overCurrentContext
                        
                        alertDialog.descString = "text_login_12".localized()
                        alertDialog.confirmString = "confirm".localized()
                        alertDialog.confirmClick = { () -> () in  }
                        present(alertDialog, animated: true, completion: nil)
                    }
                    return
                }
                
                
                // #
                let arr = result.arrayValue
                print("arr ---- \(arr)")
                
                if arr.count > 0 {
                    
                    let cellNum = arr[0]["cell_num"].stringValue
                    let birthday = arr[0]["birthymd"].stringValue
                    let use = arr[0]["use_yn"].stringValue
                    let weak_type = arr[0]["er_key"].stringValue
                    let hc_type = arr[0]["hc_type"].stringValue
                    
                    let er_key = arr[0]["er_key"].stringValue
                    let b_type = arr[0]["b_type"].stringValue
                    let g_name = arr[0]["g_name"].stringValue
                    let gcell_num = arr[0]["gcell_num"].stringValue
                    let f_mobil = arr[0]["f_mobil"].stringValue
                    let s_mobil = arr[0]["s_mobil"].stringValue
                    let name = arr[0]["nickname"].stringValue
                    
                    // # 탈퇴 회원 체크
                    if "N" == use {
                        
                        DispatchQueue.main.async {
                            [self] in
                            moveWithdrawn()
                        }
                        return
                    }
                    
                    
                    Defaults.defaults.set(name, forKey: BaseConst.SPC_USER_NAME)
                    Defaults.defaults.set(cellNum, forKey: BaseConst.SPC_USER_PHONE)
                    Defaults.defaults.set(birthday, forKey: BaseConst.SPC_USER_BIRTHDAY)
                    
                    DataShare.shared().profileDao.cell_num = cellNum
                    DataShare.shared().profileDao.passwd = arr[0]["passwd"].stringValue
                    DataShare.shared().profileDao.birthymd = birthday
                    DataShare.shared().profileDao.weak_type = weak_type
                    DataShare.shared().profileDao.hc_type = hc_type
                    DataShare.shared().profileDao.er_key = er_key
                    DataShare.shared().profileDao.b_type = b_type
                    DataShare.shared().profileDao.g_name = g_name
                    DataShare.shared().profileDao.gcell_num = gcell_num
                    DataShare.shared().profileDao.use_yn = use
                    DataShare.shared().profileDao.f_mobil = f_mobil
                    DataShare.shared().profileDao.s_mobil = s_mobil
                    DataShare.shared().profileDao.name = name
                    
                    self.moveHome()
                    
//                    self.moveRealmToDB()
                } else {
                    
                    DispatchQueue.main.async {
                        [self] in
                        
                        if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
                        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
                        alertDialog.modalTransitionStyle = .crossDissolve
                        alertDialog.modalPresentationStyle = .overCurrentContext
                        
                        alertDialog.descString = "text_login_12".localized()
                        alertDialog.confirmString = "confirm".localized()
                        alertDialog.confirmClick = { () -> () in  }
                        present(alertDialog, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func moveWithdrawn() {
        
        DispatchQueue.main.async {
            [self] in
            
            if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
            alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
            alertDialog.modalTransitionStyle = .crossDissolve
            alertDialog.modalPresentationStyle = .overCurrentContext
            
            alertDialog.descString = "text_login_13".localized()
            alertDialog.confirmString = "confirm".localized()
            alertDialog.confirmClick = { () -> () in  }
            present(alertDialog, animated: true, completion: nil)
        }
    }
    
    private func moveHome() {
        
        let sb = UIStoryboard(name: "TabBar", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
//        self.navigationController?.setViewControllers([vc], animated: true)
         
    }
    
    // MARK: 새버전에서는 Realm에서 즐찾옮기는게 필요 없음
    /*
    private func moveRealmToDB() {
        let model = realm.objects(Favorites.self)
        print("moveRealmToDB")
        print(model)
        let nickName = DataShare.shared().profileDao.name
        var modelToArray = ""
        let path:String = CommonRequest.shared.getServer() + BaseConst.NET_FAVORITE_SAVE
        var params:[String:Any] = CommonRequest.shared.getParams()
        
        // realm 모델이 있을 경우
        if !model.isEmpty {
            print("realm 모델이 있을 경우")
            for i in model {
                let arr = "\(nickName)/\(i.customName)/\(i.name)/\(i.address)/\(i.lat)/\(i.lon),"
                modelToArray += arr
            }
            print("modelToArray : \(modelToArray)")
            modelToArray = "\(modelToArray.dropLast())"
            print("modelToArray : \(modelToArray)")
            
            params["list"] = modelToArray
            
            FavoriteAPI.read_fl(nickName: nickName) { result, favoriteArray in
                if result == 0 { // db에 데이터가 없는 경우
                    print("db에 데이터가 없는 경우")
                    // 한번에 등록하기
                    CommonRequest.shared.request(path, params: params) { result in
                        let json = JSON(result)
                        print(result)
                        DispatchQueue.main.async {
                            [self] in
                            moveHome()
                        }
                    }
                } else { // db에 데이터가 있는 경우 바로 홈으로 이동
                    print("db에 데이터가 있는 경우 바로 홈으로 이동")
                    DispatchQueue.main.async {
                        [self] in
                        moveHome()
                    }
                }
            }
        } else { // realm 모델이 없을 경우 바로 홈으로 이동
            print("realm 모델이 없을 경우 바로 홈으로 이동")
            FavoriteAPI.read_fl(nickName: nickName) { result, favoriteArray in
                if result == 0 { // db에 데이터가 없는 경우
                    print("db에 데이터가 없는 경우")
                    // 초기 현위치, 집 세팅
                    modelToArray = "\(nickName)/현위치///0.0/0.0,\(nickName)/집///0.0/0.0"
                    params["list"] = modelToArray
                    CommonRequest.shared.request(path, params: params) { result in
                        let json = JSON(result)
                        print(result)
                        DispatchQueue.main.async {
                            [self] in
                            moveHome()
                        }
                    }
                } else { // db에 데이터가 있는 경우 바로 홈으로 이동
                    print("db에 데이터가 있는 경우 바로 홈으로 이동")
                    DispatchQueue.main.async {
                        [self] in
                        moveHome()
                    }
                }
            }
        }
    }
    */
}


extension InputLoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let previousText:NSString = textField.text! as NSString
        let currentText = previousText.replacingCharacters(in: range, with: string)
        validateValue()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        validateValue()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        
        validateValue()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateValue()
        if textField == tvPhone {
            tvPassword.becomeFirstResponder()
        }else if textField == tvPassword {
            tvPassword.becomeFirstResponder()
        }
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
        print("textFieldShouldBeginEditing")
        guard let placeholder = textField.placeholder else { return true }
        if placeholder == "휴대폰 번호" {
            tvPhoneSetting(hidden: true)
        }
        
        if placeholder == "비밀번호" {
            tvPasswordSetting(hidden: true)
        }
        
        textField.layer.borderColor = UIColor.inputActive?.cgColor
        
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("textFieldDidEndEditing reason")
        textField.layer.borderColor = UIColor.inputDefault?.cgColor
        validateValue()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        print("keyboardUP")
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        print("keyboardDOWN")
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.layoutIfNeeded()
        }
    }
}
