//
//  StationReviewViewController.swift
//  handycab
//
//  Created by leejungchul on 2021/07/27.
//

import UIKit
import SwiftyJSON
import Alamofire

// 리뷰 리스트 불러오는 로직 필요
class StationReviewViewController: UIViewController {

    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var writeReviewBtn: UIButton!
    @IBOutlet weak var writeReviewBtnBottomConst: NSLayoutConstraint!
    
    var nowStation: String = ""
    var nowlnCd: String = ""
    var reviewType: Int = 0
    
    var stationReivewList = [ReviewDAO]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        UsefulUtils.roundingCorner(view: writeReviewBtn)
        UsefulUtils.shadowCorner(view: writeReviewBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStationName(_:)), name: .reviewInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStationReview(_:)), name: .receiveStationReview, object: nil)
        
        print("StationReviewViewController viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        stationReivewList.removeAll()
        print("StationReviewViewController viewWillAppear")
        readReview(station: nowStation, stationLane: nowlnCd, reviewType: reviewType)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        NotificationCenter.default.removeObserver(self, name: .reviewInfo, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .receiveStationReview, object: nil)
    }
    
    @IBAction func totalReviewBtnClick(_ sender: Any) {
        /*
        let sb = UIStoryboard(name: "TabBar", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TotalReviewViewController") as! TotalReviewViewController
        vc.nowStation = nowStation
        vc.nowlnCd = nowlnCd
        vc.reviewType = reviewType
        present(vc, animated: true, completion: nil)
         */
    }
    @IBAction func writeReviewBtnClick(_ sender: Any) {
        /*
        let sb = UIStoryboard(name: "TabBar", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "WriteReviewViewController") as! WriteReviewViewController
        vc.nowStation = nowStation
        vc.nowlnCd = nowlnCd
        vc.reviewType = reviewType
        present(vc, animated: true, completion: nil)
         */
    }
    
}

extension StationReviewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = stationReivewList.count
        DispatchQueue.main.async {
            self.reviewCount.text = String(count)
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        let row = indexPath.row
        let count = stationReivewList.count
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationReviewCell", for: indexPath) as! StationReviewCell
        let reverseRow = count - row - 1
        cell.writerNickname.text = stationReivewList[reverseRow].name
        cell.writeDate.text = stationReivewList[reverseRow].writeDate
        cell.starRate1.text = stationReivewList[reverseRow].attendantStar
        cell.starRate2.text = stationReivewList[reverseRow].convenienceStar
        cell.reviewContents.text = stationReivewList[reverseRow].content
        UsefulUtils.roundingCorner(view: cell.writerImage)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

extension StationReviewViewController {
    @objc func receiveStationName(_ notification: Notification) {
        let item = notification.object as! [String]
        print("receiveStationName \(item)")
        nowStation = item[0]
        nowlnCd = item[1]
        reviewType = Int(item[2]) ?? 0
        readReview(station: nowStation, stationLane: nowlnCd, reviewType: reviewType)
    }
    // 리뷰 데이터 받는 노티
    @objc func receiveStationReview(_ notification: Notification) {
        print("receiveStationReview")
        let istoast = notification.object as! Bool
        if istoast {
            
            showToast(message: "리뷰가 작성되었습니다.", font: UIFont(name: "NotoSansCJKkr-light", size: 12.0)!)
        } else {
            showToast(message: "리뷰 작성에 실패하였습니다.", font: UIFont(name: "NotoSansCJKkr-light", size: 12.0)!)
        }
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height/2 - 20, width: 250, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
                        toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
// API 모음
extension StationReviewViewController {
    // 리뷰 리스트 불러오기
    func readReview(station: String = "", stationLane: String = "", writer: String = "", reviewType: Int = 0) -> Void {
//        if !Reachability.isConnectedToNetwork() {
//            toast(message: "network_error".localized())
//            return
//        }
        var params:[String:Any] = [
            "writer" : writer,
            "station" : station,
            "stationLane" : stationLane,
            "reviewType" : reviewType
            
        ]
        

        let path:String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_REVIEW_READ
        AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).response { response in
            switch response.result {
            case .success(let data) :
                let json = JSON(data)
                let resultArray = json.arrayValue
                for review in resultArray {
                    let tempReview = ReviewDAO()
                    tempReview.idx = review["idx"].stringValue
                    tempReview.writer = review["writer"].stringValue
                    tempReview.station = review["station"].stringValue
                    tempReview.attendantStar = review["attendantStar"].stringValue
                    tempReview.convenienceStar = review["convenienceStar"].stringValue
                    tempReview.content = review["content"].stringValue
                    tempReview.writeimage = review["writeimage"].stringValue
                    tempReview.writeDate = review["writeDate"].stringValue
                    tempReview.updateDate = review["updateDate"].stringValue
                    tempReview.stationLane = review["stationLane"].stringValue
                    tempReview.name = review["nickName"].stringValue
                    self.stationReivewList.append(tempReview)
                }
            case .failure(let error) :
                print("error : \(error.localizedDescription)")
            }
            
        }
//        CommonRequest.shared.requestJSON(path, params: params ) { (_ result: JSON) in
//            SLoader.hide()
//
//            if !result.isEmpty {
//
//                let resultArray = result.arrayValue
//
//                for review in resultArray {
//                    let tempReview = ReviewDAO()
//                    tempReview.idx = review["idx"].stringValue
//                    tempReview.writer = review["writer"].stringValue
//                    tempReview.station = review["station"].stringValue
//                    tempReview.attendantStar = review["attendantStar"].stringValue
//                    tempReview.convenienceStar = review["convenienceStar"].stringValue
//                    tempReview.content = review["content"].stringValue
//                    tempReview.writeimage = review["writeimage"].stringValue
//                    tempReview.writeDate = review["writeDate"].stringValue
//                    tempReview.updateDate = review["updateDate"].stringValue
//                    tempReview.stationLane = review["stationLane"].stringValue
//                    tempReview.name = review["nickName"].stringValue
//                    self.stationReivewList.append(tempReview)
//                }
//            } else {
//                print("empty")
//            }
//            self.tableView.reloadData()
//        }
        return
    }
}

class StationReviewCell: UITableViewCell {
    
    @IBOutlet weak var writerImage: UIImageView!
    @IBOutlet weak var writerNickname: UILabel!
    @IBOutlet weak var writeDate: UILabel!
    @IBOutlet weak var starRate1: UILabel!
    @IBOutlet weak var starRate2: UILabel!
    @IBOutlet weak var reviewContents: UILabel!
}
