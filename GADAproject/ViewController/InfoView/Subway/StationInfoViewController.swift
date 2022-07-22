//
//  TTViewController.swift
//  handycab
//
//  Created by leejungchul on 2021/07/28.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

// 사진 사이즈 조정 필요
class StationInfoViewController: UIViewController {

    @IBOutlet weak var subwayInfoLabel: UILabel!
    @IBOutlet weak var subwayStationImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
        
    var imageHeight: CGFloat = 200.0
    
    var stationInfo = [String:[[String]]]()
    
    var subwayConvenientInfoList = [[String]]()
    
    var subwayLineInfo = SubwayLineModel()
    
    var imageRawUrl = ""
    var lnCd = ""
    var railOprIsttCd = ""
    var stinCd = ""
    var phoneNumber = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("StationInfoViewController viewDidLoad")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSubwayConvenientInfo(_:)), name: .receiveSubwayConvenientInfo, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSubwayInfo(_:)), name: .receiveSubwayInfo, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .receiveSubwayConvenientInfo, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .receiveSubwayInfo, object: nil)
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stationPhoneBtnClick(_ sender: UIButton) {
        var phoneNumber: String = ""
        
        let path: String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_STATION_PHONE
        
        var params: [String:Any] = [
            "stinCd" : subwayLineInfo.stinCd,
            "stinNm" : subwayLineInfo.stinNm,
            "routCd" : subwayLineInfo.routCd
        ]
        // MARK: 테스트 필요
        AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).responseString { response in
            switch response.result {
            case .success(let data):
                UsefulUtils.callTo(phoneNumber: data)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    @IBAction func tapFavoritebtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}

extension StationInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stationInfo.count == 0 {
            return 2
        }
        return stationInfo.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        let row = indexPath.row - 1
        
        let imageCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! InfoCell
        if row == -1 {
            print("imageCell \(imageHeight)")
            let imageUrl = URL(string: imageRawUrl) ?? URL(string: "")
            
            imageCell.stationInfoImage.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
            imageCell.stationInfoImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "nullImage"))
            imageCell.expandImageBtn.addTarget(self, action: #selector(expandImageBtnClick), for: .touchUpInside)
            imageCell.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
            return imageCell
        } else {
            print("infoCell")
            if stationInfo.isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "데이터가 존재하지 않습니다."
                cell.textLabel?.font = UIFont(name: "NotoSansCJKkr-Bold", size: 16.0)
                return cell
            }
            let floorList = Array(stationInfo.keys).sorted()
            
            infoCell.floor.text = "\(floorList[row])층"
            print("\(floorList[row])층")
            let loop = stationInfo[floorList[row]]!.count
            for i in 1 ..< loop {
                let detailText = stationInfo[floorList[row]]![i][0]
                let locationText = stationInfo[floorList[row]]![i][5]
                infoCell.addDetailLabel(detail: detailText, location: locationText, loop: i)
            }
            infoCell.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
            return infoCell
        }
    }
    
    @objc func expandImageBtnClick(sender : UIButton!) {
        /*
        let vc = UIStoryboard(name: "Orientation", bundle: nil).instantiateViewController(withIdentifier: "StationInfoExpandViewController") as! StationInfoExpandViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        vc.imageRawUrl = imageRawUrl
        vc.stationInfo = stationInfo
        present(vc, animated: true, completion: nil)
         */
    }
    
}

extension StationInfoViewController {
    
    @objc func receiveSubwayInfo(_ notification: Notification) {
        print("receiveSubwayInfo")
        let item = notification.object as! SubwayLineModel
        subwayLineInfo = item
        let laneCd = subwayLineInfo.lnCd
        lnCd = SubwayUtils.shared().laneCdChange(laneCd: laneCd)
        stinCd = subwayLineInfo.stinCd
        railOprIsttCd = subwayLineInfo.railOprIsttCd
        
        subwayInfoLabel.text = "\(subwayLineInfo.stinNm)역"
//        subwayStationLabel.text = subwayLineInfo.stinNm
        
        let changeData = SubwayUtils.shared().laneCdChange(laneCd: lnCd)
        print("changeData : \(changeData), laneCd: \(laneCd), lnCd: \(lnCd)")
        
        subwayStationImage.image = UIImage(named: "circle_line_\(changeData)_24")
        
        subwayStationInfo(stinCd: subwayLineInfo.stinCd)
        
        subwayConvenientInfoCall(lnCd: subwayLineInfo.lnCd, railOprIsttCd: subwayLineInfo.railOprIsttCd, stinCd: subwayLineInfo.stinCd)
        
        NotificationCenter.default.post(name: .reviewInfo, object: [subwayLineInfo.stinNm, subwayLineInfo.lnCd, "0"])
        
        
    }
    
    @objc func receiveSubwayConvenientInfo(_ notification: Notification) {
        print("receiveSubwayInfo")
        guard let item = notification.object as? [[String]] else { return }
        var url = ""
        /*
        let gubun : 시설구분 (EV: 엘리베이터, ES: 에스컬레이터, WCLF: 휠체어 리프트, ELEC: 전동 휠체어 충전 설비, TOLT: 화장실, INFO: 고객센터, FEED: 수유실)
        let mlFmlDvCd : 남녀구분 (1: 남자, 2: 여자, 3: 공용)
        let stinFlor : 역층
        let trfcWeakDvCd : 교통약자구분 (1: 일반, 2: 교통약자)
        let grndDvCd : 지상지하구분 (1: 지상, 2:지하)
        let dtlLoc : 상세위치
        */
        for var i in item {
            
            if i[4] == "1" {
                i[4] = "지상"
            } else {
                i[4] = "지하"
            }
            stationInfo[i[4]+i[2], default: [["append"]]].append(i)
            if i[6] != "" {
                url = i[6]
            }
            print(i)
        }
        tableView.reloadData()
        print("stationInfo", stationInfo)
        imageRawUrl = url
//        // 이미지 안나올때 처리 요망
        guard let imageUrl = URL(string: imageRawUrl) else { return }
        let tempUrl = ImageResource(downloadURL: imageUrl)
        KingfisherManager.shared.retrieveImage(with: tempUrl, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                print("Image size: \(value.image.size). Got from: \(value.cacheType)")
                let ratio = value.image.size.height / value.image.size.width
                self.imageHeight = self.tableView.frame.width * ratio
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func subwayStationInfo(stinCd: String) {
        print("func subwayStationInfo call stinCd : \(stinCd)")
        ODsayService.sharedInst().requestSubwayStationInfo(stinCd, responseBlock: { (retCode: Int32, resultDic:[AnyHashable : Any]?) in
            if retCode == 200 {
                let jsonResult = JSON(resultDic)["result"]
                self.phoneNumber = jsonResult["defaultInfo"]["tel"].stringValue
            } else {
                print("fail")
            }
        })
    }
    
    // 도시철도 역사편의정보 API
    private func subwayConvenientInfoCall(lnCd: String, railOprIsttCd: String, stinCd: String) {
        print("도시철도 역사편의정보 API")
        print("도시철도 역사편의정보 API \(lnCd), \(railOprIsttCd), \(stinCd)")
        let para : Parameters = [
            "serviceKey": "$2a$10$o/DL6MPbsjRS2llxGiiOH.wSfVCQ12fX35EXR39AlcGWAtztWle0O",
            "format": "json",
            "lnCd": lnCd,
            "railOprIsttCd": railOprIsttCd,
            "stinCd": stinCd
            
        ]
        AF.request("http://openapi.kric.go.kr/openapi/convenientInfo/stationCnvFacl",parameters: para, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                let jsonHeader = JSON(data)["header"]
                let jsonBody = JSON(data)["body"]
                if jsonHeader["resultCode"].stringValue == "03" {
                    NotificationCenter.default.post(name: .receiveSubwayConvenientInfo, object: self.subwayConvenientInfoList)
                    break
                }
                let imgPath = jsonBody[0]["imgPath"].stringValue
                // 이미지 경로 오류로 경로 변경
                var updateImgPath = imgPath.split(separator: ".")
                updateImgPath[1] = "kric.go"
                var reCreateImgPath:String = ""
                let number = updateImgPath.count
                for (i, v) in updateImgPath.enumerated() {
                    reCreateImgPath += v
                    if i != number - 1 {
                        reCreateImgPath += "."
                    }
                }
                for i in jsonBody {
                    var gubun = i.1["gubun"].stringValue
                    let mlFmlDvCd = i.1["mlFmlDvCd"].stringValue
                    let stinFlor = i.1["stinFlor"].stringValue
                    let trfcWeakDvCd = i.1["trfcWeakDvCd"].stringValue
                    let grndDvCd = i.1["grndDvCd"].stringValue
                    let dtlLoc = i.1["dtlLoc"].stringValue
                    //(EV: 엘리베이터, ES: 에스컬레이터, WCLF: 휠체어 리프트, ELEC: 전동 휠체어 충전 설비, TOLT: 화장실, INFO: 고객센터, FEED: 수유실)
                    switch gubun {
                    case "EV":
                        gubun = "엘리베이터"
                    case "ES":
                        gubun = "에스컬레이터"
                    case "WCLF":
                        gubun = "휠체어리프트"
                    case "ELEC":
                        gubun = "전동휠체어 충전설비"
                    case "TOLT":
                        gubun = "화장실"
                    case "INFO":
                        gubun = "고객센터"
                    case "FEED":
                        gubun = "수유실"
                    default:
                        gubun = "엘리베이터"
                    }
                    self.subwayConvenientInfoList.append([gubun, mlFmlDvCd, stinFlor, trfcWeakDvCd, grndDvCd, dtlLoc, reCreateImgPath])
                }
                NotificationCenter.default.post(name: .receiveSubwayConvenientInfo, object: self.subwayConvenientInfoList)
                break
            case .failure(let error):
                print("error: \(error)")
                break
            }
        }
    }
    
}
