import UIKit
import SwiftyJSON
import SwiftyUserDefaults
import Alamofire


class LoginViewController: UIViewController {

    
    @IBOutlet weak var tvTitleLabel: UILabel!
    @IBOutlet weak var btnFindPassword: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var btnCustomerCenter: UIButton!
    
    
    private var confirmDialog:ConfirmPopupView!
    private var alertDialog:AlertPopupView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        tvTitleLabel.text = "text_login_1".localized()
        
        // 비밀번호 찾기
        btnFindPassword.setTitle("text_login_6".localized(), for: UIControl.State.normal)
        btnFindPassword.isAccessibilityElement = true
        btnFindPassword.accessibilityLabel = "text_login_6".localized()
        btnFindPassword.accessibilityHint = "text_login_6".localized()
        
        // 로그인
        btnLogin.setTitle("text_login_4".localized(), for: UIControl.State.normal)
        btnLogin.isAccessibilityElement = true
        btnLogin.accessibilityLabel = "text_login_4".localized()
        btnLogin.accessibilityHint = "text_login_4".localized()
        
        // 회원가입
        btnJoin.setTitle("text_login_7".localized(), for: .normal)
        btnJoin.isAccessibilityElement = true
        btnJoin.accessibilityLabel = "text_login_7".localized()
        btnJoin.accessibilityHint = "text_login_7".localized()
        
        // 고객센터
        btnCustomerCenter.setTitle("text_login_8".localized(), for: .normal)
        btnCustomerCenter.isAccessibilityElement = true
        btnCustomerCenter.accessibilityLabel = "text_login_8".localized()
        btnCustomerCenter.accessibilityHint = "text_login_8".localized()
        
        // #
        confirmDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "ConfirmPopupView") as! ConfirmPopupView)
        confirmDialog.modalTransitionStyle = .crossDissolve
        confirmDialog.modalPresentationStyle = .overCurrentContext
        
        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
        alertDialog.modalTransitionStyle = .crossDissolve
        alertDialog.modalPresentationStyle = .overCurrentContext
        
        /*
        "text_login_1" = "Handycab";
        "text_login_2" = "전화번호 입력";
        "text_login_3" = "비밀번호 입력";
        "text_login_4" = "로그인";
        "text_login_5" = "비밀번호를 잊어버리셨나요?";
        "text_login_6" = "비밀번호 찾기";
        "text_login_7" = "회원가입";
        "text_login_8" = "고객센터";
        "text_login_9" = "전화번호를 입력해주세요.";
        "text_login_10" = "비밀번호를 입력해주세요.";
        "text_login_11" = "로그인 정보를 확인해주세요.";
        */
        
        /*
        최초 진입 시 비활성화 상태이며, 아이디 6글자
        이상 + 비밀번호 8글자 이상 입력 시 버튼 활성화
        아이디는 전화번호인 관계로 01x로 시작하는지 체크가 필요하고 10-11자리까지 입력되었는지 체크 필요함
        로그인 성공시 자동 로그인 되도록 처리함
        */
        
        // #
        
        /*
        #if DEBUG
        tvPhone.text = "01071813390"
        
        #endif
        */
        
    }
    
    @IBAction func joinClick(_ sender: UIButton) {
     
        
//        let storyBoard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "JoinViewController") as! JoinViewController
//        vc.modalTransitionStyle = .crossDissolve
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // # 비밀번호 찾기
    @IBAction func findPasswordClick(_ sender: UIButton) {
        
//        let storyBoard:UIStoryboard = UIStoryboard(name: "Member", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "FindPasswordViewController") as! FindPasswordViewController
//        vc.modalTransitionStyle = .crossDissolve
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // # 고객센터
    @IBAction func customerCenterClick(_ sender: UIButton) {
        let url = BaseConst.SERVICE_SERVER_HOST + "/TrafficPathTraced/callCenter"
        AF.request(url, method: .post).responseString { response in
            switch response.result {
            case .success(let data):
                UsefulUtils.callTo(phoneNumber: data)
            case .failure(let error):
                print(error)
            default:
                print("Error!!")
            }
        }
    }
    
    @IBAction func goToLoginPage(_ sender: Any) {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "inputLoginViewController") as! InputLoginViewController
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func tabTestBtn(_ sender: Any) {
        
        let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
