//
//  SubwayInfoViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/11.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class SubwayStationInfoViewController: UIViewController {

    @IBOutlet weak var stationLaneImage: UIImageView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var subwayLineInfo: SubwayModelBody?
    var subwayConvenientInfoList = [String]()
    
    var imageHeight: CGFloat = 200.0
    var stationInfo = [String:[[String]]]()
    var imageRawUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        print("subwayLiseInfo : \(subwayLineInfo)")
        self.dataSetting()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveSubwayInfo(_:)), name: .receiveSubwayInfo, object: nil)
    }
    @IBAction func tapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func stationPhoneBtnClick(_ sender: UIButton) {
        var phoneNumber: String = ""
        
        let path: String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_STATION_PHONE
        print(
            "stinCd", subwayLineInfo?.stinCd,
            "stinNm", subwayLineInfo?.stinNm,
            "routCd", subwayLineInfo?.routCd
        )
        var params: [String:Any] = [
            "stinCd" : subwayLineInfo?.stinCd ?? "",
            "stinNm" : subwayLineInfo?.stinNm ?? "",
            "routCd" : subwayLineInfo?.routCd ?? ""
        ]
        // MARK: 테스트 필요
        AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).responseString { response in
            print(response.result)
            switch response.result {
            case .success(let data):
                UsefulUtils.callTo(phoneNumber: data)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}
extension SubwayStationInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stationInfo.count == 0 {
            return 2
        }
        return stationInfo.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row - 1
        if row == -1 {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
            
            let imageUrl = URL(string: imageRawUrl) ?? URL(string: "")
        
            imageCell.stationInfoImage.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
            imageCell.stationInfoImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "nullImage"))
            imageCell.expandImageBtn.addTarget(self, action: #selector(expandImageBtnClick), for: .touchUpInside)
            return imageCell
        } else {
            print("infoCell")
            let infoCell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
            
            if self.stationInfo.isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "데이터가 존재하지 않습니다."
                cell.textLabel?.font = UIFont.pretendard(type: .bold, size: 16.0)
                return cell
            }
            let floorList = Array(stationInfo.keys).sorted()
            
            print("infoCell : \(floorList)")
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
        print("click")
        let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "SubwayStationExpandInfoViewController") as! SubwayStationExpandInfoViewController
        vc.stationImageURL = imageRawUrl
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SubwayStationInfoViewController {
//    @objc func receiveSubwayInfo(_ notification: Notification) {
//        print("receiveSubwayInfo : ", notification)
//        print("receiveSubwayInfo : ", notification.object)
//        guard let item = notification.object as? SubwayModelBody else { return }
//        print("receiveSubwayInfo : ", item)
//        self.subwayLineInfo = item
//        dataSetting()
//    }

    func dataSetting() {
        let laneCd = subwayLineInfo?.lnCd

        let stationName = subwayLineInfo?.stinNm ?? ""
        let stationNameCount = stationName.contains("(") ? stationName.count - 2 : stationName.count
        if stationNameCount > 9 && stationName.contains("(") {
            stationNameLabel.text = stationName.components(separatedBy: "(")[0]
        } else {
            stationNameLabel.text = stationName
        }
        
        stationLaneImage.image = UIImage(named: "circle_line_\(subwayLineInfo?.lnCd ?? "")_16")
        
//        subwayStationInfo(stinCd: subwayLineInfo.stinCd)
        
        subwayConvenientInfoCall(lnCd: subwayLineInfo!.lnCd, railOprIsttCd: subwayLineInfo!.railOprIsttCd, stinCd: subwayLineInfo!.stinCd)
    }
    // 도시철도 역사편의정보 API
    func subwayConvenientInfoCall(lnCd: String, railOprIsttCd: String, stinCd: String) {
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
                print("jsonBody : ",jsonBody)
                print(jsonHeader)
                if jsonHeader["resultCode"].stringValue == "03" {
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
                var makeData = [[String]]()
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
                        if trfcWeakDvCd == "1" {
                            if mlFmlDvCd == "1" {
                                gubun = "화장실(남)"
                            } else if mlFmlDvCd == "2" {
                                gubun = "화장실(여)"
                            } else {
                                gubun = "화장실(공용)"
                            }
                        } else {
                            if mlFmlDvCd == "1" {
                                gubun = "교통약자 화장실(남)"
                            } else if mlFmlDvCd == "2" {
                                gubun = "교통약자 화장실(여)"
                            } else {
                                gubun = "교통약자 화장실(공용)"
                            }
                        }
                    case "INFO":
                        gubun = "고객센터"
                    case "FEED":
                        gubun = "수유실"
                    default:
                        gubun = "엘리베이터"
                    }
                    makeData.append([gubun, mlFmlDvCd, stinFlor, trfcWeakDvCd, grndDvCd, dtlLoc, reCreateImgPath])
                }
                self.makeDataForUser(item: makeData)
                break
            case .failure(let error):
                print("error: \(error)")
                break
            }
        }
    }
      
    /*
    func subwayStationInfo(stinCd: String) {
        print("func subwayStationInfo call stinCd : \(stinCd)")
        ODsayService.sharedInst().requestSubwayStationInfo(stinCd, responseBlock: { (retCode: Int32, resultDic:[AnyHashable : Any]?) in
            print("func subwayStationInfo call stinCd", retCode)
            if retCode == 200 {
                let jsonResult = JSON(resultDic)["result"]
                print("func subwayStationInfo call stinCd", jsonResult)
                self.phoneNumber = jsonResult["defaultInfo"]["tel"].stringValue
            } else {
                print("fail")
            }
        })
    }
     */
    
    func makeDataForUser(item: [[String]]) {
        
//        guard let item = notification.object as? [[String]] else { return }
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
            print("I : ", i)
        }
        
        print("stationInfo", stationInfo)
        tableView.reloadData()
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
}
