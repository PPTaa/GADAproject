import UIKit
import SwiftyJSON
import SwiftyUserDefaults
import FirebaseAuth
import RealmSwift
import Alamofire


class JoinViewController: UIViewController {
    
    @IBOutlet weak var tvTitle:UILabel!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var bottomView:UIView!
    
    @IBOutlet weak var btnConfirm:UIButton!
    @IBOutlet weak var btnConfirmBottomConst: NSLayoutConstraint!
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnNextWidthConst: NSLayoutConstraint!
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressViewTrailConst: NSLayoutConstraint!
    
    private var pageContainer: UIPageViewController!
    private var pages = [UIViewController]()
    private var currentIndex: Int? = 0
    private var pendingIndex: Int? = 0
//    private var joinPage0: JoinTermsViewController!
    private var joinPage0: JoinServiceTermViewController!
    private var joinPage1: JoinPhoneViewController!
    private var joinPage2: JoinPasswordViewController!
//    private var joinPage3: JoinNickNameViewController!
    
    private var joinPage3: JoinTypeViewController!
    private var joinPage4: JoinHandicabViewController!
    private var joinPage5: JoinFirstTrafficViewController!
    
    private var joinPage6: JoinEmergencyNumberViewController!
    
    private var joinPage12: JoinCompleteViewController!
    
    
    private var type:String!
    private var change:Bool!
    
    private var confirmDialog:ConfirmPopupView!
    private var alertDialog:AlertPopupView!
    
    private var currentVerificationId:String = ""
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinViewController", #function)
        
        self.btnNext.layer.borderColor = UIColor.buttonActive?.cgColor
        self.btnNext.layer.borderWidth = 1
        self.btnNextWidthConst.constant = 0
        
        self.progressViewTrailConst.constant = view.layer.frame.width
        
        //--------------------------------------------------
        NotificationCenter.default.addObserver(self,
           selector: #selector(didRecieveNotification(_:)),
           name: .joinNoti,
           object: nil)
        NotificationCenter.default.addObserver(self,
           selector: #selector(keyboardWillShow),
           name: UIResponder.keyboardWillShowNotification,
           object: nil)
        NotificationCenter.default.addObserver(self,
           selector: #selector(keyboardWillHide),
           name: UIResponder.keyboardWillHideNotification,
           object: nil)
        //--------------------------------------------------
        
        
        // #
        DataShare.shared().joindao = JoinDao()
        
        
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        
        joinPage0 = (storyboard.instantiateViewController(withIdentifier: "JoinServiceTermViewController") as! JoinServiceTermViewController)
        joinPage1 = (storyboard.instantiateViewController(withIdentifier: "joinPage1") as! JoinPhoneViewController)
        joinPage2 = (storyboard.instantiateViewController(withIdentifier: "joinPage2") as! JoinPasswordViewController)
//        joinPage3 = (storyboard.instantiateViewController(withIdentifier: "joinPage3") as! JoinNickNameViewController)
        
        joinPage3 = (storyboard.instantiateViewController(withIdentifier: "joinPage3") as! JoinTypeViewController)
        joinPage4 = (storyboard.instantiateViewController(withIdentifier: "joinPage4") as! JoinHandicabViewController)
        joinPage5 = (storyboard.instantiateViewController(withIdentifier: "joinPage5") as! JoinFirstTrafficViewController)
        joinPage6 = (storyboard.instantiateViewController(withIdentifier: "joinPage6") as! JoinEmergencyNumberViewController)
        pages.append(joinPage0)
        pages.append(joinPage1)
        pages.append(joinPage2)
        pages.append(joinPage3)
        
        pages.append(joinPage4)
        pages.append(joinPage5)
        pages.append(joinPage6)
        
        joinPage12 = (storyboard.instantiateViewController(withIdentifier: "joinPage12") as! JoinCompleteViewController)
        
        pages.append(joinPage12)
        
        pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        pageContainer.delegate = self
        pageContainer.dataSource = self
        
        pageContainer.isPagingEnabled = false
        
        
        pageContainer.setViewControllers([joinPage0], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        pageContainer.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        containerView.addSubview(pageContainer.view)
        
        
        
        // #
        joinPage12.confirmClick = { () -> () in
            DispatchQueue.main.async {
                [self] in
                
                let id = DataShare.shared().joindao.cell_num
                let pwd = DataShare.shared().joindao.passwd
                requestLogin(id: id, pwd: pwd)
            }
        }
        
        joinPage12.failClick = { () -> () in
            DispatchQueue.main.async {
                [self] in
                
                if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
                alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
                alertDialog.modalTransitionStyle = .crossDissolve
                alertDialog.modalPresentationStyle = .overCurrentContext
                
                alertDialog.descString = "text_join_33".localized()
                alertDialog.confirmString = "confirm".localized()
                alertDialog.confirmClick = { () -> () in  }
                present(alertDialog, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .joinNoti, object: nil)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        super.viewDidDisappear(animated)
    }
    
    @objc func didRecieveNotification(_ notification: Notification) {
    
        guard let isActive: Bool = notification.object as? Bool else { return }
        print("join-noti-op :", isActive)
        
        if isActive {
            btnConfirm.isEnabled = true
            btnConfirm.backgroundColor = UIColor.buttonActive
            btnConfirm.setTitleColor(UIColor.textBtnActive, for: .normal)
        } else {
            btnConfirm.isEnabled = false
            btnConfirm.backgroundColor = UIColor.buttonDisabled
            btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
        }
    }

    @IBAction func backClick(_ sender: UIButton) {
        
        print("--> back")
        self.navigationController?.popViewController(animated: true)
//        dismiss(animated: true)
    }
    
    @IBAction func previousClick(_ sender: Any) {
        
        if currentIndex == 0 { // MARK: 약관 페이지에서 뒤로가기 하는 경우
            self.navigationController?.popViewController(animated: true)
        } else if currentIndex == 1 { // MARK: 본인인증 페이지에서 뒤로가기 하는 경우
            currentIndex = 0
            self.progressViewTrailConst.constant = view.layer.frame.width * 7 / 7
            
            btnConfirm.setTitle("next".localized(), for: .normal)
            btnConfirm.accessibilityLabel = "다음"
            btnConfirm.accessibilityHint = "다음 회원가입 절차로 이동힙니다."
            
            btnConfirm.isEnabled = true
            btnConfirm.backgroundColor = UIColor.buttonActive
            btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
            
            pageContainer.goToPreviousPage()
        } else if currentIndex == 2 { // MARK: 비밀번호설정 페이지에서 뒤로가기 하는 경우
            currentIndex = 1
            self.progressViewTrailConst.constant = view.layer.frame.width * 6 / 7
            joinPage1.tvPhoneLabel.text = ""
            joinPage1.tvVerificationCode.text = ""
            joinPage1.tvVerificationCode.isHidden = true
            joinPage1.tvPhoneSetting(hidden: true)
            joinPage1.tvVerificationSetting(hidden: true)
            joinPage1.authVerification = false
            
            btnConfirm.setTitle("auth".localized(), for: .normal)
            btnConfirm.accessibilityLabel = "인증번호 전송"
            btnConfirm.accessibilityHint = "휴대폰 번호를 인증힙니다."
            btnConfirm.isEnabled = true
            btnConfirm.backgroundColor = UIColor.buttonActive
            btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
            
            pageContainer.goToPreviousPage()
        } else if currentIndex == 3 { // MARK: 약자유형 페이지에서 뒤로가기 하는 경우
            currentIndex = 2
            self.progressViewTrailConst.constant = view.layer.frame.width * 5 / 7
            
            btnConfirm.setTitle("next".localized(), for: .normal)
            btnConfirm.accessibilityLabel = "다음"
            btnConfirm.accessibilityHint = "다음 절차로 이동힙니다."
            btnConfirm.isEnabled = true
            btnConfirm.backgroundColor = UIColor.buttonActive
            btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
            
            pageContainer.goToPreviousPage()
        } else if currentIndex == 4 { // MARK: 장애유형 페이지에서 뒤로가기 하는 경우
            currentIndex = 3
            self.progressViewTrailConst.constant = view.layer.frame.width * 4 / 7
            
            btnConfirm.setTitle("next".localized(), for: .normal)
            btnConfirm.accessibilityLabel = "다음"
            btnConfirm.accessibilityHint = "다음 절차로 이동힙니다."
            btnConfirm.isEnabled = true
            btnConfirm.backgroundColor = UIColor.buttonActive
            btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
            
            pageContainer.goToPreviousPage()
        } else if currentIndex == 5 { // MARK: 선호교통수단 페이지에서 뒤로가기 하는 경우
            if joinPage3.getValue().contains("1") {
                currentIndex = 4
                
                self.progressViewTrailConst.constant = view.layer.frame.width * 3 / 7
                
                btnConfirm.setTitle("next".localized(), for: .normal)
                btnConfirm.accessibilityLabel = "다음"
                btnConfirm.accessibilityHint = "다음 절차로 이동힙니다."
                btnConfirm.isEnabled = true
                btnConfirm.backgroundColor = UIColor.buttonActive
                btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
                
                pageContainer.setViewControllers([joinPage4], direction: UIPageViewController.NavigationDirection.reverse, animated: false, completion: nil)
            } else {
                currentIndex = 3
                
                self.progressViewTrailConst.constant = view.layer.frame.width * 4 / 7
                
                btnConfirm.setTitle("next".localized(), for: .normal)
                btnConfirm.accessibilityLabel = "다음"
                btnConfirm.accessibilityHint = "다음 절차로 이동힙니다."
                btnConfirm.isEnabled = true
                btnConfirm.backgroundColor = UIColor.buttonActive
                btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
                
                pageContainer.setViewControllers([joinPage3], direction: UIPageViewController.NavigationDirection.reverse, animated: false, completion: nil)
            }
        
        } else if currentIndex == 6 { // MARK: 긴급연락처 페이지에서 뒤로가기 하는 경우
            currentIndex = 5
            self.progressViewTrailConst.constant = view.layer.frame.width * 2 / 7
            
            btnConfirm.setTitle("next".localized(), for: .normal)
            btnConfirm.accessibilityLabel = "다음"
            btnConfirm.accessibilityHint = "다음 절차로 이동힙니다."
            btnConfirm.isEnabled = true
            btnConfirm.backgroundColor = UIColor.buttonActive
            btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
            btnNextWidthConst.constant = 0
            
            pageContainer.goToPreviousPage()
            
        }
    }
    
    @IBAction func confirmClick(_ sender: UIButton) {
        
        // # 약관 체크
        if currentIndex == 0 {
            
            if !joinPage0.isValidate() {
                
                DispatchQueue.main.async {
                    [self] in
                    
                    if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
                    alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
                    alertDialog.modalTransitionStyle = .crossDissolve
                    alertDialog.modalPresentationStyle = .overCurrentContext
                    
                    alertDialog.descString = "text_join_9".localized()
                    alertDialog.confirmString = "confirm".localized()
                    alertDialog.confirmClick = { () -> () in  }
                    present(alertDialog, animated: true, completion: nil)
                }
                
                return
            }
            
            // 닉네임 생성
            getRandomString()
            
            // 본인인증 페이지로 넘어갈때 버튼 변경
            btnConfirm.setTitle("auth".localized(), for: .normal)
            btnConfirm.accessibilityLabel = "인증번호 전송"
            btnConfirm.accessibilityHint = "휴대폰 번호를 인증힙니다."
            btnConfirm.isEnabled = false
            btnConfirm.backgroundColor = UIColor.buttonDisabled
            btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
            
            // 페이지 변경시 진행도 표시
            self.progressViewTrailConst.constant = view.layer.frame.width * 6 / 7
            
            currentIndex = 1
            self.pageContainer.setViewControllers([joinPage1], direction: .forward, animated: false, completion: nil)
        }
        
        // MARK: 전화번호 체크
        else if currentIndex == 1 {
            
            // 번호 인증 된 경우
            
            if joinPage1.authVerification {
                joinPage1.isValidate { (bool) in
                    if bool {
                        
                        DataShare.shared().joindao.cell_num = self.joinPage1.getValue()

                        self.currentIndex = 2
                        self.btnConfirm.setTitle("next".localized(), for: .normal)
                        self.btnConfirm.accessibilityLabel = "다음"
                        self.btnConfirm.accessibilityHint = "다음 회원가입 절차로 이동힙니다."
                        
                        self.btnConfirm.isEnabled = false
                        self.btnConfirm.backgroundColor = UIColor.buttonDisabled
                        self.btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
                        
                        print("nextPAge")
                        // 페이지 변경시 진행도 표시
                        self.progressViewTrailConst.constant = self.view.layer.frame.width * 5 / 7
                        self.pageContainer.setViewControllers([self.joinPage2], direction: .forward, animated: false, completion: nil)
                        
                    }
                }
            } else {
                joinPage1.firebaseAuth { bool in
                    print("firebaseAuth = ", bool)
                    if bool {
                        self.btnConfirm.isEnabled = false
                        self.btnConfirm.backgroundColor = UIColor.buttonDisabled
                        self.btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
                        self.btnConfirm.setTitle("인증 완료", for: .normal)
                        self.joinPage1.authVerification = true
                    }
                }
            }

        }
        
        // MARK: 비밀번호 설정 및 확인
        else if currentIndex == 2 {
            
            if self.joinPage2.getValue()[0] != self.joinPage2.getValue()[1] {
                joinPage2.tvAlertRe.text = "text_join_15".localized()
                joinPage2.tvAlertRe.textColor = .red
                return
            } else {
                joinPage2.tvAlertRe.text = "위와 동일한 번호를 다시 입력해주세요."
                joinPage2.tvPasswordReSetting(hidden: true)
            }
            
            if !joinPage2.isValidate() {
                print("isValidate -- ")
                return
            }

            DataShare.shared().joindao.passwd = self.joinPage2.getValue()[0]
            
            // #
            currentIndex = 3
            
            self.btnConfirm.isEnabled = false
            self.btnConfirm.backgroundColor = UIColor.buttonDisabled
            self.btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
            
            // 페이지 변경시 진행도 표시
            self.progressViewTrailConst.constant = view.layer.frame.width * 4 / 7
            
            self.pageContainer.setViewControllers([joinPage3], direction: .forward, animated: false, completion: nil)
        }
        
        // MARK: 해당하는 항목 (장애인, 임산부, 노약자)
        else if currentIndex == 3 {
            var weak_type: String = ""
                        
            print(joinPage3.getValue())
            var result = joinPage3.getValue().sorted()
            
            for i in result {
                weak_type += i
            }
            print(weak_type)
            
            DataShare.shared().joindao.weak_type = weak_type
            
            if joinPage3.getValue().contains("1") {
                self.currentIndex = 4
                
                self.btnConfirm.isEnabled = false
                self.btnConfirm.backgroundColor = UIColor.buttonDisabled
                self.btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
                
                // 페이지 변경시 진행도 표시
                self.progressViewTrailConst.constant = view.layer.frame.width * 3 / 7
                
                pageContainer.setViewControllers([joinPage4], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
            } else {
                self.currentIndex = 5
                
                self.btnConfirm.isEnabled = false
                self.btnConfirm.backgroundColor = UIColor.buttonDisabled
                self.btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
                
                // 페이지 변경시 진행도 표시
                self.progressViewTrailConst.constant = view.layer.frame.width * 2 / 7
                
                pageContainer.setViewControllers([joinPage5], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
            }
        }
        
        // MARK: 해당하는 항목 (장애인체크시 랜딩)
        else if currentIndex == 4 {
            var hc_type: String = ""
            
//            if !joinPage4.isValidate() {
//                return
//            }
            
            print(joinPage4.getValue())
            var result = joinPage4.getValue()
            result.sort()
            for i in result {
                hc_type += i
            }
            print(hc_type)
            
            // 생년월일 대신 가입일시 등록
            let date = DateFormatter()
            date.locale = Locale(identifier: "ko_kr")
            date.timeZone = TimeZone(abbreviation: "KST")
            date.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = date.string(from: Date())
            
            DataShare.shared().joindao.birthymd = now
            DataShare.shared().joindao.hc_type = hc_type
            currentIndex = 5
            
            self.btnConfirm.isEnabled = false
            self.btnConfirm.backgroundColor = UIColor.buttonDisabled
            self.btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
            
            // 페이지 변경시 진행도 표시
            self.progressViewTrailConst.constant = view.layer.frame.width * 2 / 7
            pageContainer.setViewControllers([joinPage5], direction: .forward, animated: false, completion: nil)
        }
        
        // MARK: 가장 선호하는 교통수단
        else if currentIndex == 5 {
            
            if !joinPage5.isValidate() {
                return
            }
            
            DataShare.shared().joindao.f_mobil = joinPage5.getValue()

            btnConfirm.setTitle("확인", for: .normal)
            btnConfirm.accessibilityLabel = "회원가입 완료"
            btnConfirm.accessibilityHint = "회원가입을 완료합니다."
        
            self.btnConfirm.isEnabled = false
            self.btnConfirm.backgroundColor = UIColor.buttonDisabled
            self.btnConfirm.setTitleColor(UIColor.textSecondary, for: .normal)
            
            // 다음에 하기 버튼 생성
            self.btnNextWidthConst.constant = view.layer.frame.width / 2
        
            currentIndex = 6
            
            // 페이지 변경시 진행도 표시
            self.progressViewTrailConst.constant = view.layer.frame.width / 7
        
            pageContainer.setViewControllers([joinPage6], direction: .forward, animated: false)
        }
        
        else if currentIndex == 6 { // MARK: 긴급 연락처 입력
            
            btnPrevious.isHidden = true
            
            btnConfirm.setTitle("자동 로그인하기", for: .normal)
            btnConfirm.accessibilityLabel = "자동 로그인하기"
            btnConfirm.accessibilityHint = "자동으로 로그인합니다."
            
            self.btnConfirm.isEnabled = true
            self.btnConfirm.backgroundColor = UIColor.buttonActive
            self.btnConfirm.setTitleColor(UIColor.textPrimary, for: .normal)
            
            // 다음에 하기 버튼 삭제
            self.btnNextWidthConst.constant = 0
            
            DataShare.shared().joindao.gcell_num = joinPage6.getValue()
            
            // 페이지 변경시 진행도 표시
            self.progressViewTrailConst.constant = 0
            
            currentIndex = 12
            pageContainer.setViewControllers([joinPage12], direction: .forward, animated: false) { (bool) in
                DispatchQueue.main.async {
                    [self] in
                    joinPage12.requestJoin()
                }
            }
        }
        
        
        else if currentIndex == 12 {
            DispatchQueue.main.async {
                [self] in
                
                let id = DataShare.shared().joindao.cell_num
                let pwd = DataShare.shared().joindao.passwd
                requestLogin(id: id, pwd: pwd)
            }
        }
        
        print(DataShare.shared().profileDao)
    }
    
    @IBAction func tapBtnNext(_ sender: Any) {
        btnPrevious.isHidden = true
        
        btnConfirm.setTitle("자동 로그인하기", for: .normal)
        btnConfirm.accessibilityLabel = "자동 로그인하기"
        btnConfirm.accessibilityHint = "자동으로 로그인합니다."
        
        // 다음에 하기 버튼 삭제
        self.btnNextWidthConst.constant = 0
        
        DataShare.shared().joindao.gcell_num = joinPage6.getValue()
        
        currentIndex = 12
        pageContainer.setViewControllers([joinPage12], direction: .forward, animated: false) { (bool) in
            DispatchQueue.main.async {
                [self] in
                joinPage12.requestJoin()
            }
        }
    }
    
    private func requestLogin(id:String, pwd:String) -> Void {
        
//        if !Reachability.isConnectedToNetwork() {
//
//            toast(message: "network_error".localized())
//            return
//        }
        
        SLoader.showLoading()
        
        var params:[String:Any] = [
            "cell_num" : id,
            "passwd" : pwd
        ]
        
        let path:String = CommonRequest.shared.getServer() + BaseConst.NET_MEMBER_LOGIN
        
        CommonRequest.shared.request(path, params: params as! [String : String]) {
            
            (_ result: JSON) in
            
            SLoader.hide()
            
            if !result.isEmpty {
                
                print(result)
                print(result["code"].intValue)
                
                // # 등록 성공 시
                if result["code"].intValue == 200 {
                    
                    Defaults.defaults.setValue(true, forKey: BaseConst.SPC_USER_LOGIN)
                    Defaults.defaults.setValue(id, forKey: BaseConst.SPC_USER_ID)
                    Defaults.defaults.setValue(pwd, forKey: BaseConst.SPC_USER_PWD)
                    
                    DispatchQueue.main.async {
                        [self] in
                        requestProfile()
                    }
                }
                
                else {
                    
                    DispatchQueue.main.async {
                        [self] in
                        
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
        
//        if !Reachability.isConnectedToNetwork() {
//
//            toast(message: "network_error".localized())
//            return
//        }
        
        SLoader.showLoading()
        
        var params:[String:Any] = [
            "cell_num" : Defaults.defaults.string(forKey: BaseConst.SPC_USER_ID),
            "passwd" : Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD)
        ]
        
//        CommonRequest.shared.getParams()
//        params["cell_num"] = Defaults.defaults.string(forKey: BaseConst.SPC_USER_ID)
//        params["passwd"] = Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD)
        
        let path:String = CommonRequest.shared.getServer() + BaseConst.NET_MEMBER_INFO
        
        CommonRequest.shared.requestJSON(path, params: params as! [String : String]) {
            
            (_ result: JSON) in
            
            SLoader.hide()
            
            if !result.isEmpty {
                
                print(result)
                
                // # 예외 처리
                if "0" == result["code"].stringValue {
                    
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
                    return
                }
                
                
                // #
                let arr = result.arrayValue
//                CommonUtils.log( arr.count )
                
                if arr.count > 0 {
                    
                    
                    let cellNum = arr[0]["cell_num"].stringValue
                    let birthday = arr[0]["birthymd"].stringValue
                    let use = arr[0]["use_yn"].stringValue
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
                            // moveWithdrawn()
                        }
                        return
                    }
                    
                    
                    Defaults.defaults.set(name, forKey: BaseConst.SPC_USER_NAME)
                    Defaults.defaults.set(cellNum, forKey: BaseConst.SPC_USER_PHONE)
                    Defaults.defaults.set(birthday, forKey: BaseConst.SPC_USER_BIRTHDAY)
                    
                    
                    DataShare.shared().profileDao.cell_num = cellNum
                    DataShare.shared().profileDao.passwd = arr[0]["passwd"].stringValue
                    DataShare.shared().profileDao.birthymd = birthday
                    DataShare.shared().profileDao.hc_type = hc_type
                    DataShare.shared().profileDao.er_key = er_key
                    DataShare.shared().profileDao.b_type = b_type
                    DataShare.shared().profileDao.g_name = g_name
                    DataShare.shared().profileDao.gcell_num = gcell_num
                    DataShare.shared().profileDao.use_yn = use
                    DataShare.shared().profileDao.f_mobil = f_mobil
                    DataShare.shared().profileDao.s_mobil = s_mobil
                    DataShare.shared().profileDao.name = name
                    
                    
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
                
                // [{"cell_num":"01071813390","passwd":"solter0807","birthymd":"20200101","hc_type":1,"er_key":"y","b_type":1,"g_name":"홍길동","gcell_num":"1071813390","use_yn":"Y","NUM":0}]
            }
        }
    }
    
    // MARK: realm 이사 미사용
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
    
    
    // MARK: 홈으로 이동 페이지 구성후 풀기
    private func moveHome() {
        print(#function)
        
        let sb = UIStoryboard(name: "TabBar", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        window.rootViewController = vc
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.25

        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in
        })
        
    }
    
    private func getRandomString() {
        let url = "https://nickname.hwanmoo.kr/"
        let params: [String : Any] = [
            "format": "text",
            "count": 1,
            "max_length": 20
        ]
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).responseString { response in
            switch response.result {
            case .success(let data):
                DataShare.shared().joindao.name = data
            case .failure(let error):
                print(error)
            }
        }
    }
    
 
}

// 키보드 관련 익스텐션
extension JoinViewController {
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        print("keyboardUP")
//        print("before \(btnLogin.frame.origin.y)")
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if screenHeight < 750 {
                self.btnConfirmBottomConst.constant = keyboardHeight
            } else {
                self.btnConfirmBottomConst.constant = keyboardHeight - 34
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        print("keyboardDOWN")
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.btnConfirmBottomConst.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}


extension JoinViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
   
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        print("viewControllerBefore",viewControllerIndex)
        return (previousIndex == -1) ? nil : pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        print("viewControllerAfter",viewControllerIndex)
        return (nextIndex == pages.count) ? nil : pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("pendingIndex : \(pendingIndex)")
        pendingIndex = pages.firstIndex(of:pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        print("didFinishAnimating : \(finished)")
        print("pendingIndex : \(pendingIndex)")
        print("transitionCompleted : \(completed)")
        if completed {
            
            currentIndex = pendingIndex
            
        }
    }
    
    
    
}
