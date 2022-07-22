import UIKit
import SwiftyJSON
import SwiftyUserDefaults
import Alamofire


/**
 - note: 
 */
class JoinCompleteViewController: UIViewController {
    
    public var confirmClick: (() -> ())?
    public var failClick: (() -> ())?
    
    private var confirmDialog:ConfirmPopupView!
    private var alertDialog:AlertPopupView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinCompleteViewController", #function)
        
        // #
        confirmDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "ConfirmPopupView") as! ConfirmPopupView)
        confirmDialog.modalTransitionStyle = .crossDissolve
        confirmDialog.modalPresentationStyle = .overCurrentContext
        
        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
        alertDialog.modalTransitionStyle = .crossDissolve
        alertDialog.modalPresentationStyle = .overCurrentContext
                
        
        /*
        "text_join_1" = "이용약관";
        "text_join_2" = "모든 약관에 동의합니다.";
        "text_join_3" = "서비스 이용약관";
        "text_join_4" = "(필수)";
        "text_join_5" = "개인정보 처리방침";
        "text_join_6" = "위치기반 서비스 이용약관";
        "text_join_7" = "(선택)";
        "text_join_8" = "법정공지 및 정보제공처";
        "text_join_9" = "모든 필수 약관에 동의해주세요.";
        "text_join_10" = "휴대폰번호";
        "text_join_11" = "가입이 된 번호입니다.";
        "text_join_12" = "휴대폰번호를 정확히 입력해주세요.";
        "text_join_13" = "8글자 이상 영문/숫자를 사용해주세요.";
        "text_join_14" = "가입이 된 번호입니다.";
        "text_join_15" = "비밀번호가 불일치합니다.";
        "text_join_16" = "010.1234.5678";
        "text_join_17" = "0000.00.00";
        "text_join_18" = "생년월일을 입력해주세요.";
        "text_join_19" = "불편한 곳을 선택해주세요.";
        "text_join_20" = "응급상황을 대비하여\n추가정보를\n작성하시겠습니까?";
        "text_join_21" = "본인 혈액형";
        "text_join_22" = "보호자 이름";
        "text_join_23" = "홍길동";
        "text_join_24" = "보호자 연락처";
        "text_join_25" = "환영합니다!";
        "text_join_26" = "회원가입이 완료되었습니다!\n로그인 후 HANDYCAB 서비스를\n이용할 수 있습니다.";
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func confirmClick(_ sender: UIButton) {
        
    
        confirmClick!()
    }
    
    
    public func requestJoin() -> Void {
        
        SLoader.showLoading()
                
        let dao: JoinDao = DataShare.shared().joindao!
        
        
        var params:[String:Any] = [
          "category": dao.weak_type,
          "cell_num": dao.cell_num,
          "f_mobil": Int(dao.f_mobil) ?? 0,
          "nickname": dao.name,
          "optional_terms_yn": 1,
          "required_terms_yn": 1,
          "passwd": dao.passwd,
          "tool_type": dao.hc_type
        ]
        /*
        cell_num    핸드폰번호    String
        passwd      비밀번호    String
        weak_type     장애형태    String
        hc_type     장애형태    String
        f_mobil     가장선호하는수단  int
        s_mobil     두번째로선호하는수단  int
        name        사용자설정닉네임  String
        사용하지 않는 정보
        birthymd    생년월일    string
        er_key      응급정보    char
        b_type      혈액형    int
        g_name      보호자이름    string
        gcell_num   보호자연락처    int
        */
        
        print("requestJoin--------", params)
        
        let path:String = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_GADA_REGISTER
        
        AF.request(path, method: .post, parameters: params, encoding: JSONEncoding.default, headers: BaseConst.headers).responseString { response in
            switch response.result {
            case .success(let data):
                print("--------data",data)
                let result = JSON(data)
                if !result.isEmpty {
                    print(result)
                    print(result["code"].intValue)
                    // # 등록 성공 시
                    if result["code"].intValue == 200 {
                        SLoader.hide()
                        
                    } else { // 등록 실패시
                        DispatchQueue.main.async {
                            [self] in
                            failClick!()
                        }
                    }
                }
            case .failure(let error):
                print("--------error",error.localizedDescription)
            }
        }
    }
}
