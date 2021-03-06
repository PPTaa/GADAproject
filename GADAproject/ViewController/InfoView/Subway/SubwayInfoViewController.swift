//
//  SubwayInfoViewController.swift
//  GADA
//
//  Created by leejungchul on 2022/07/04.
//

import Foundation
import PagingKit
import Alamofire
import SwiftyJSON
import UIKit

class SubwayInfoViewController: UIViewController {
    
    @IBOutlet weak var subwayInfoLabel: UILabel!
    @IBOutlet weak var subwayStationLabel: UILabel!
    @IBOutlet weak var subwayStationImage: UIImageView!
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    var subwayConvenientInfoList = [[String]]()
    var phoneNumber = ""
    
    var subwayLineInfo = SubwayLineModel()
    var lnCd = ""
    var railOprIsttCd = ""
    var stinCd = ""
    
    static var viewController: (UIColor) -> UIViewController = { (color) in
        let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    var dataSource = [(menu: String, content: UIViewController)]() {
        didSet{
            menuViewController.reloadData()
            contentViewController.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuViewController.register(nib: UINib(nibName: "InfoMenuCell", bundle: nil), forCellWithReuseIdentifier: "InfoMenuCell")
        menuViewController.registerFocusView(nib: UINib(nibName: "InfoFocusView", bundle: nil))
        menuViewController.cellSpacing
        
        dataSource = makeDataSource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSubwayInfo(_:)), name: .receiveSubwayInfo, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .receiveSubwayInfo, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self
            contentViewController.delegate = self
        }
    }
    
    fileprivate func makeDataSource() -> [(menu: String, content: UIViewController)] {
        let myMenuArray = ["??? ????????????" , "????????? ??????"]
        
        return myMenuArray.map{
            let title = $0
            switch title {
            case "?????? ????????????":
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "stationInfoViewController") as! StationInfoViewController
                return (menu: title, content: vc)
            case "????????? ??????":
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "stationReviewViewController") as! StationReviewViewController
                return (menu: title, content: vc)
            default:
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "stationInfoViewController") as! StationInfoViewController
                return (menu: title, content: vc)
            }
        }
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stationPhoneBtnClick(_ sender: UIButton) {
        var phoneNumber: String = ""
        
        let path: String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_STATION_PHONE
        print(
            "stinCd", subwayLineInfo.stinCd,
            "stinNm", subwayLineInfo.stinNm,
            "routCd", subwayLineInfo.routCd
        )
        var params: [String:Any] = [
            "stinCd" : subwayLineInfo.stinCd,
            "stinNm" : subwayLineInfo.stinNm,
            "routCd" : subwayLineInfo.routCd
        ]
        // MARK: ????????? ??????
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

// MARK: Notification
extension SubwayInfoViewController {
    
    @objc func receiveSubwayInfo(_ notification: Notification) {
        print("receiveSubwayInfo")
        let item = notification.object as! SubwayLineModel
        subwayLineInfo = item
        let laneCd = subwayLineInfo.lnCd
        lnCd = SubwayUtils.shared().laneCdChange(laneCd: laneCd)
        stinCd = subwayLineInfo.stinCd
        railOprIsttCd = subwayLineInfo.railOprIsttCd
        
        subwayInfoLabel.text = "\(subwayLineInfo.stinNm)??? ????????????"
        subwayStationLabel.text = subwayLineInfo.stinNm
        
        let changeData = SubwayUtils.shared().laneCdChange(laneCd: lnCd)
        print("changeData : \(changeData), laneCd: \(laneCd), lnCd: \(lnCd)")
        
        subwayStationImage.image = UIImage(named: "circle_line_\(changeData)_24")
        
        subwayStationInfo(stinCd: subwayLineInfo.stinCd)
        
        subwayConvenientInfoCall(lnCd: subwayLineInfo.lnCd, railOprIsttCd: subwayLineInfo.railOprIsttCd, stinCd: subwayLineInfo.stinCd)
        
        NotificationCenter.default.post(name: .reviewInfo, object: [subwayLineInfo.stinNm, subwayLineInfo.lnCd, "0"])
        
        
    }
}

// MARK: APICall
extension SubwayInfoViewController {
    // ???????????? ?????????????????? API
    private func subwayConvenientInfoCall(lnCd: String, railOprIsttCd: String, stinCd: String) {
        print("???????????? ?????????????????? API")
        print("???????????? ?????????????????? API \(lnCd), \(railOprIsttCd), \(stinCd)")
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
                // ????????? ?????? ????????? ?????? ??????
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
                    //(EV: ???????????????, ES: ??????????????????, WCLF: ????????? ?????????, ELEC: ?????? ????????? ?????? ??????, TOLT: ?????????, INFO: ????????????, FEED: ?????????)
                    switch gubun {
                    case "EV":
                        gubun = "???????????????"
                    case "ES":
                        gubun = "??????????????????"
                    case "WCLF":
                        gubun = "??????????????????"
                    case "ELEC":
                        gubun = "??????????????? ????????????"
                    case "TOLT":
                        gubun = "?????????"
                    case "INFO":
                        gubun = "????????????"
                    case "FEED":
                        gubun = "?????????"
                    default:
                        gubun = "???????????????"
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
}

extension SubwayInfoViewController: PagingMenuViewControllerDataSource {
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "InfoMenuCell", for: index) as! InfoMenuCell
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return UIScreen.main.bounds.width / 2
    }
    
    
}

extension SubwayInfoViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
    
}

extension SubwayInfoViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}

extension SubwayInfoViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}
