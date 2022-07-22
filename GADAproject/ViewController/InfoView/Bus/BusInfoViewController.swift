//
//  BusInfoViewController.swift
//  handycab
//
//  Created by leejungchul on 2022/04/13.
//

import Foundation
import Alamofire
import PagingKit
import SwiftyJSON
import UIKit

class BusInfoViewController: UIViewController {
    
    @IBOutlet weak var busNoLabel: UILabel!
    @IBOutlet weak var busWayLabel: UILabel!
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    var busLocalBlID: String = ""
    var busRouteInfoItem = RouteInfoItem() {
        didSet {
            guard let busLabel = busRouteInfoItem.busRouteNm else { return }
            var busNo = ""
            var busWay = ""
            let busLabelList = Array(busLabel)
            for (idx,char) in busLabel.enumerated() {
                print("busLabel.enumerated()", char, char.isCased, char.isLetter)
                if char.isCased {
                    busNo = busLabel.substring(from: 0, to: idx+1)
                    busWay = busLabel.substring(from: idx+1, to: busLabel.count)
                    break
                }
                if char.isLetter {
                    if idx == 0 {
                        busNo = busLabel
                        busWay = ""
                    } else {
                        busNo = busLabel.substring(from: 0, to: idx)
                        busWay = busLabel.substring(from: idx, to: busLabel.count)
                    }
                    break
                }
            }
            print("busNo, busWay : ", busNo, busWay)
            busNoLabel.text = busLabel
            if busWay == "" {
                busWayLabel.text = ""
            } else {
                busNoLabel.text = busNo
                busWayLabel.text = "(\(busWay)방향)"
            }
            
        }
    }
    
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
        busRouteInfoCall(busLocalBlID: busLocalBlID)
        
        menuViewController.register(nib: UINib(nibName: "InfoMenuCell", bundle: nil), forCellWithReuseIdentifier: "InfoMenuCell")
        menuViewController.registerFocusView(nib: UINib(nibName: "InfoFocusView", bundle: nil))
        menuViewController.cellSpacing
        
        dataSource = makeDataSource()
    }
    
    @IBAction func tapBusPhoneCall(_ sender: UIButton) {
        guard let corpNm = busRouteInfoItem.corpNm else { return }
        let phoneNum = corpNm.components(separatedBy: " ")
        print(corpNm)
        if phoneNum.count == 1 {
            // 전화번호 없을때의 로직
        } else {
            guard let callNum = phoneNum.last else { return }
            UsefulUtils.callTo(phoneNumber: callNum)
        }
        print(phoneNum)
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
        let myMenuArray = ["버스 정보안내" , "서비스 리뷰"]
        
        return myMenuArray.map{
            let title = $0
            switch title {
            case "버스 정보안내":
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "BusDetailInfoViewController") as! BusDetailInfoViewController
                vc.busLocalBlID = self.busLocalBlID
                return (menu: title, content: vc)
            case "서비스 리뷰":
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "stationReviewViewController") as! StationReviewViewController
                return (menu: title, content: vc)
            default:
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "stationInfoViewController") as! StationInfoViewController
                return (menu: title, content: vc)
            }
        }
    }
    
    func busRouteInfoCall(busLocalBlID: String) {
        let para : Parameters = [
            "serviceKey": BaseConst.BUS_API_KEY,
            "busRouteId": busLocalBlID,
            "resultType": "json"
        ]
        AF.request("http://ws.bus.go.kr/api/rest/busRouteInfo/getRouteInfo",parameters: para, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(BusRouteInfo.self, from: jsonData)
                    guard let item = getInstanceData.msgBody?.itemList?[0] else { return }
                    self.busRouteInfoItem = item
                    NotificationCenter.default.post(name: .busRouteInfoData, object: item)
                    NotificationCenter.default.post(name: .reviewInfo, object: [item.busRouteNm, item.busRouteId, "1"])
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("error: \(error)")
                break
            }
        }
    }
}

extension BusInfoViewController: PagingMenuViewControllerDataSource {
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

extension BusInfoViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
    
}

extension BusInfoViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}

extension BusInfoViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}
