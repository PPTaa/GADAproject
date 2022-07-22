//
//  SurveySubjectiveViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class SurveySubjectiveViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var surveyTitleLabel: UILabel!
    
    @IBOutlet weak var surveyQuestion1View: UIView!
    @IBOutlet weak var surveyQuestion1: UITextField!
    
    @IBOutlet weak var surveyQuestion2View: UIView!
    @IBOutlet weak var surveyQuestion2: UITextField!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        surveyQuestion1View.layer.cornerRadius = 2
        surveyQuestion1View.layer.borderWidth = 1
        surveyQuestion1View.layer.borderColor = UIColor.inputDefault?.cgColor
        
        surveyQuestion2View.layer.cornerRadius = 2
        surveyQuestion2View.layer.borderWidth = 1
        surveyQuestion2View.layer.borderColor = UIColor.inputDefault?.cgColor
                
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        let convertDate = dateFormatter.string(from: Date())
        dateLabel.text = convertDate
    }

    @IBAction func sendQuestion(_ sender: Any) {
        DataShare.shared().subjectDataList = [(date: dateLabel.text ?? "", title: surveyTitleLabel.text ?? "", answer1: surveyQuestion1.text ?? "", answer2: surveyQuestion2.text ?? "")]
        sendQuestionData()
    }
    
    @IBAction func tapGoToMain(_ sender: Any) {
        goToMain()
    }
    
    func sendQuestionData() {
        let path = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_GADA_QUESTION_SUBJECTIVE
        let url = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let params: [String: Any] = [
            "question_name": surveyTitleLabel.text ?? "",
            "answer": surveyQuestion1.text ?? "",
            "reason": surveyQuestion2.text ?? ""
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: BaseConst.headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                print(data)
                let jsonData = JSON(data)
                if jsonData["code"].stringValue == "200" {
                    self.goToMain()
                } else {
                    // 저장이 안되었을 경우의 에러 처리
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func goToMain() {
        let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


