//
//  BusDetailInfoViewController.swift
//  handycab
//
//  Created by leejungchul on 2022/04/13.
//

import Foundation
import UIKit
import Alamofire

class BusDetailInfoViewController: UIViewController {
    
    @IBOutlet weak var busNoLabel: UILabel!
    @IBOutlet weak var busWayLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startStation: UILabel!
    @IBOutlet weak var endStation: UILabel!
    @IBOutlet weak var routeType: UILabel!
    @IBOutlet weak var betweenBusesLabel: UILabel!
    @IBOutlet weak var startRouteTime: UILabel!
    @IBOutlet weak var endRouteTime: UILabel!
    
    let routeTypeList = ["공용", "공항", "마을", "간선", "지선", "순환", "광역", "인천", "경기", "폐기"]
    var busLocalBlID: String = ""
    var busRouteInfoItem = RouteInfoItem() {
        didSet {
            print("RouteInfoItem", busRouteInfoItem)
            
            self.startStation.text = busRouteInfoItem.stStationNm
            self.endStation.text = busRouteInfoItem.edStationNm
            self.betweenBusesLabel.text = "배차간격 \(busRouteInfoItem.term ?? "0")분"
            self.routeType.text = "\(self.routeTypeList[Int(busRouteInfoItem.routeType ?? "0")!])"
            
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
    
    var tableCellList = [RouteListItem]() {
        didSet{
            let firstbeginTm = tableCellList[0].beginTm ?? ""
            let firstlastTm = tableCellList[0].lastTm ?? ""
            
            let endbeginTm = tableCellList.last?.beginTm ?? ""
            let endlastTm = tableCellList.last?.lastTm ?? ""
            
            if firstbeginTm == " " && firstlastTm == " " {
                self.startRouteTime.text = "정보 없음"
            } else {
                self.startRouteTime.text = "\(firstbeginTm)~\(firstlastTm)"
            }
            if endbeginTm == " " && endlastTm == " " {
                self.endRouteTime.text = "정보 없음"
            } else {
                self.endRouteTime.text = "\(endbeginTm)~\(endlastTm)"
            }
            self.tableView.reloadData()
        }
    }
    
    var busLocationData = [BusLocationItem]() {
        didSet {
            print("\(self.busLocationData.count) 대 운행중!!!!!")
            self.tableView.reloadData()
        }
    }
    var dateFormatter = DateFormatter()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        busRouteInfoCall(busLocalBlID: self.busLocalBlID)
        stationsByRouteListCall(busLocalBlID: self.busLocalBlID)
        busLocationById(busLocalBlID: self.busLocalBlID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivebusRouteInfoData(_:)), name: .busRouteInfoData, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .busRouteInfoData, object: nil)
    }
    
    
    @IBAction func tapBackBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tapFavoritebtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
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
}
// MARK: 사용 API 모음
extension BusDetailInfoViewController {
    
    func stationsByRouteListCall(busLocalBlID: String) {
        let para : Parameters = [
            "serviceKey": BaseConst.BUS_API_KEY,
            "busRouteId": busLocalBlID,
            "resultType": "json"
        ]
        AF.request("http://ws.bus.go.kr/api/rest/busRouteInfo/getStaionByRoute",parameters: para, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(StaionsByRouteList.self, from: jsonData)
                    guard let itemList = getInstanceData.msgBody?.itemList else { return }
                    print("a4a4a44a",itemList)
                    self.tableCellList = itemList
                    
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("error: \(error)")
                break
            }
        }
    }
    
    func busLocationById(busLocalBlID: String) {
        let para : Parameters = [
            "serviceKey": BaseConst.BUS_API_KEY,
            "busRouteId": busLocalBlID,
            "resultType": "json"
        ]
        AF.request("http://ws.bus.go.kr/api/rest/buspos/getBusPosByRtid",parameters: para, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(BusLocationById.self, from: jsonData)
                    guard let itemList = getInstanceData.msgBody?.itemList else { return }
                    for i in itemList {
                        print("sectDist - ", i.sectDist, "rtDist - ", i.rtDist, "fullSectDist - ", i.fullSectDist, "i.stopFlag - ", i.stopFlag)
                    }
                    self.busLocationData = itemList
                    
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("error: \(error)")
                break
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

// MARK: BusRouteInfoData noti 수신
extension BusDetailInfoViewController {
    @objc func receivebusRouteInfoData(_ noti: Notification) {
        guard let item = noti.object as? RouteInfoItem else { return }
        print("item item item",item)
        busRouteInfoItem = item
    }
}

extension BusDetailInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusInfoTableCell", for: indexPath) as! BusInfoTableCell
        let row = indexPath.row
        cell.upperLine.isHidden = true
        cell.lowerLine.isHidden = true
        cell.stationTitle.textColor = .textPrimary
        cell.stationNumber.textColor = .textSecondary
        if tableCellList[row].transYn == "Y" {
            for i in busLocationData {
                if i.sectOrd == tableCellList[row].seq {
                    break
                } else {
                    cell.stationIcon.image = UIImage(named: "busTransIcon")
                }
            }
            cell.stationTitle.text = "[회차] " + tableCellList[row].stationNm!
            cell.stationTitle.textColor = .primaryGreen600
            cell.stationNumber.textColor = .primaryGreen600
        } else {
            cell.upperLine.backgroundColor = .baseGray300
            cell.lowerLine.backgroundColor = .baseGray300
            for i in busLocationData {
                cell.stationIcon.isHidden = false
                if i.sectOrd == tableCellList[row].seq {
                    cell.busIcon.isHidden = false
                    if i.stopFlag == "1" {
                        if i.sectDist != "0" {
                            cell.busIconCenterConst.constant = 20
                        } else {
                            cell.stationIcon.isHidden = true
                            cell.busIconCenterConst.constant = 0
                        }
                    } else {
                        cell.busIconCenterConst.constant = -20
                    }
                    break
                } else {
                    cell.busIcon.isHidden = true
                    cell.stationIcon.image = UIImage(named: "chevron_down_circle_24")
                    cell.busIconCenterConst.constant = 0
                }
            }
            
            cell.stationTitle.text = tableCellList[row].stationNm
            cell.stationTitle.textColor = .textPrimary
        }
        cell.stationNumber.text = tableCellList[row].stationNo
        
        if row == 0 {
            cell.lowerLine.isHidden = false
        } else if row == tableCellList.count - 1 {
            cell.upperLine.isHidden = false
        } else {
            cell.upperLine.isHidden = false
            cell.lowerLine.isHidden = false
        }
        return cell
    }
    
    
    
}
