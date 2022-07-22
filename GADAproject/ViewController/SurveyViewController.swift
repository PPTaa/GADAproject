//
//  SurveyViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import AnimatedCollectionViewLayout

class SurveyViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionContentLabel: UILabel!
    
    @IBOutlet weak var baseLineView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    let dateFormatter = DateFormatter()
    var selectedIdx = 0
    
    var questionContentLabelList: [String] = ["햇살이 따스한 카페", "집앞 공원으로의 산책", "수다떨수 있는 친구네 집", "새로운 풍경을 볼 수 있는 곳"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        cardCollectionView.isPagingEnabled = true
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        let convertDate = dateFormatter.string(from: Date())
        
        dateLabel.text = convertDate
        questionContentLabel.text = questionContentLabelList[0]
        
        let collectionViewLayout = AnimatedCollectionViewLayout()
        collectionViewLayout.animator = LinearCardAttributesAnimator()
        collectionViewLayout.scrollDirection = .horizontal
        cardCollectionView.collectionViewLayout = collectionViewLayout

    }
    
    @IBAction func tapGoToMain(_ sender: Any) {
        goToMain()
    }
    
}

extension SurveyViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SurveyCardCell", for: indexPath) as! SurveyCardCell
    

        cell.cardImage.image = UIImage(named: "card_image_\(row + 1)")
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.cardImage.layer.cornerRadius = 10
        cell.cardImage.layer.borderWidth = 1
        cell.cardImage.layer.borderColor = UIColor.clear.cgColor
        cell.cardImage.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SurveyCardCell
        
        sendQuestionData(cell: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
extension SurveyViewController {
    // 페이징 인덱스
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee
        let idx = offset.x / view.frame.width
//        0.25 0.5 0.75 1.0
//        0      1    2   3
        print(idx)
        selectedIdx = Int(idx)
        
        let fullLineWidth = baseLineView.frame.width-40
        print(fullLineWidth * (0.25 + idx * 0.25))
        let contentLabel = questionContentLabelList[Int(idx)]
        DispatchQueue.main.async {
            self.lineViewWidth.constant = fullLineWidth * (0.25 + idx * 0.25)
            self.questionContentLabel.text = contentLabel
//            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
//                self.lineViewWidth.constant = fullLineWidth * (0.25 + idx * 0.25)
//                self.questionContentLabel.text = contentLabel
//            }, completion: nil)
        }
    }
}
// MARK: API 전송
extension SurveyViewController {
    //
    func sendQuestionData(cell: SurveyCardCell) {
        let path = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_GADA_QUESTION
        let url = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let params: [String: Any] = [
            "number": selectedIdx,
            "question_name": self.questionTitleLabel.text ?? ""
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: BaseConst.headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                print(data)
                let jsonData = JSON(data)
                if jsonData["code"].stringValue == "200" {
                    self.multipleRatioCall()
                    self.checkPercent(cell: cell)
                } else {
                    // 저장이 안되었을 경우의 에러 처리
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    //
    func checkPercent(cell: SurveyCardCell) {
        let url = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_GADA_QUESTION_PERCENT
        
        let params: [String: Any] = [
            "number": selectedIdx,
            "question_name": self.questionTitleLabel.text ?? ""
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: BaseConst.headers).responseString { response in
            switch response.result {
            case .success(let data):
                print(Double(data))
                let text = ""
                let image = UIImage()
                let doubleData = Double(data) ?? 0.0
                let textData = Int(floor(doubleData))
                let intData = self.roundToTens(x: doubleData)
                
                print("1")
                DispatchQueue.main.async {
                    cell.percentLabel.text = "\(textData)%"
                    cell.percentImage.image = UIImage(named: "percent_\(intData)")
                    
                    cell.coverView.isHidden = false
                    cell.percentImage.isHidden = false
                    cell.percentLabel.isHidden = false
                    
                    print("2")
                }
                
                print("3")
                let group = DispatchGroup()
                let semaphore = DispatchSemaphore(value: 4)
                DispatchQueue.global().async(group: group) {
                    // 3초간 쓰레드 휴식
                    sleep(3)
                    DispatchQueue.main.async {
                        self.goToMain()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func multipleRatioCall() {
        let path = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_GADA_QUESTION_ALL_PERCENT
        let url = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        print("questionName", self.questionTitleLabel.text)
        let params: [String: Any] = [
            "questionName": self.questionTitleLabel.text!
        ]
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: BaseConst.headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                print("multipleRatioCall", data)
                let jsonData = JSON(data).arrayValue
                var percentList = [Double]()
                for i in jsonData {
                    percentList.append(round(i["ratio"].doubleValue))
                }
                DataShare.shared().multipleDataList = [(date: self.dateLabel.text!, title: self.questionTitleLabel.text!, selectNum: self.selectedIdx, allQuestion: self.questionContentLabelList, percentData: percentList)]
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func roundToTens(x : Double) -> Int {
        return 10 * Int(floor(x / 10.0)) == 0 ? 10 : 10 * Int(floor(x / 10.0)) + 10
    }
    
    func goToMain() {
        let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
