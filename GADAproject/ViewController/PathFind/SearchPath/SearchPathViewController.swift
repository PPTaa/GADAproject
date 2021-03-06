//
//  SearchPathViewController.swift
//  handycab
//
//  Created by leejungchul on 2021/09/30.
//

import TMapSDK
import UIKit
import ODsaySDK
import SwiftyJSON
import RealmSwift
import CoreLocation
import Alamofire

class SearchPathViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var allPathBtn: UIButton!
    @IBOutlet weak var customPathBtn: UIButton!
    @IBOutlet weak var shortPathBtn: UIButton!
    @IBOutlet weak var busPathBtn: UIButton!
    @IBOutlet weak var subwayPathBtn: UIButton!
    
    
    
    public static var endLocation: String = ""
    
    let laneViewRadius: CGFloat = 2.0
    
    var searchModelLists: Array<SearchPathModel> = [SearchPathModel]()
    
    let realm = try! Realm()
    
    public static var pathType = 1
    var myType = 0
    var exchangeVar = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
//        UsefulUtils.roundingCorner(view: allPathBtn)
//        UsefulUtils.roundingCorner(view: customPathBtn)
//        UsefulUtils.roundingCorner(view: shortPathBtn)
//        UsefulUtils.roundingCorner(view: busPathBtn)
//        UsefulUtils.roundingCorner(view: subwayPathBtn)
        allPathBtn.isSelected = true
        allPathBtn.layer.cornerRadius = 16
        
        if DataShare.shared().profileDao.f_mobil == "1" {
            myType = 2
        } else if DataShare.shared().profileDao.f_mobil == "2" {
            myType = 1
        } else {
            myType = 0
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(recieveLoactionData(_:)), name: .recieveLoactionData, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: .recieveLoactionData, object: nil)
    }
    
    @IBAction func tapExchangeBtn(_ sender: Any) {
        
        let tempData = SearchViewController.startLatLon
        let tempLocationString = SearchViewController.startLocationString
        
        SearchViewController.startLatLon = SearchViewController.endLatLon
        SearchViewController.startLocationString = SearchViewController.endLocationString
        
        SearchViewController.endLatLon = tempData
        SearchViewController.endLocationString = tempLocationString
        
        // type = 0 : ??????(?????????+??????) 1 : ?????????, 2 : ??????
        // pathType = 1 : ??????, 2 : ??????, 3 : ??????, 4 : ?????????
        let typeList = [0, myType, 0, 2, 1]
        
        searchPathData(searchPathType: typeList[SearchPathViewController.pathType])
        
        startLabel.text = SearchViewController.startLocationString
        endLabel.text = SearchViewController.endLocationString
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        // exit segue??? ?????? ?????? ??????
        performSegue(withIdentifier: "moveToRoot", sender: nil)
    }
    
    // type = ?????? ??????
    // 0 : ??????(?????????+??????) 1 : ?????????, 2 : ??????
    @IBAction func allPathBtnClick(_ sender: UIButton) {
        buttonSelect(button: sender)
        if SearchPathViewController.pathType == 0 {
            return
        }
        SearchPathViewController.pathType = 0
        searchPathData(searchPathType: 0)
    }
    
    @IBAction func customPathBtnClick(_ sender: UIButton) {
        buttonSelect(button: sender)
        if SearchPathViewController.pathType == 1 {
            return
        }
        tableView.isScrollEnabled = false
        SearchPathViewController.pathType = 1
        searchPathData(searchPathType: myType)
        tableView.isScrollEnabled = true
    }
    @IBAction func shortPathBtnClick(_ sender: UIButton) {
        buttonSelect(button: sender)
        if SearchPathViewController.pathType == 2 {
            return
        }
        SearchPathViewController.pathType = 2
        searchPathData(searchPathType: 0)
    }
    @IBAction func busPathBtnClick(_ sender: UIButton) {
        buttonSelect(button: sender)
        if SearchPathViewController.pathType == 3 {
            return
        }
        SearchPathViewController.pathType = 3
        searchPathData(searchPathType: 2)
    }
    @IBAction func subwayPathBtnClick(_ sender: UIButton) {
        buttonSelect(button: sender)
        if SearchPathViewController.pathType == 4 {
            return
        }
        SearchPathViewController.pathType = 4
        searchPathData(searchPathType: 1)
    }
    
    func buttonSelect(button: UIButton) {
        allPathBtn.isSelected = false
        customPathBtn.isSelected = false
        shortPathBtn.isSelected = false
        busPathBtn.isSelected = false
        subwayPathBtn.isSelected = false
        
        button.isSelected = true
    }
    
}

extension SearchPathViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchModelLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        
        if searchModelLists.count == 0 {
            print("searchModelLists -------------------")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PathViewCell") as! PathViewCell
        let row = indexPath.row
        if row < 0 {
            // ?????????????????? ?????? ?????? ?????? ??????
            return cell
        }
        
        print("searchModelLists[row].detailPathData : \(searchModelLists[row].detailPathData)")
        
        let sumTime = searchModelLists[row].sectionTime.reduce(0, +)
        let cellWidth = tableView.frame.size.width - 40
        var widthList = [CGFloat]()
        for i in 0 ..< searchModelLists[row].sectionTime.count {
            print(cellWidth)
            print("\(CGFloat(self.searchModelLists[row].sectionTime[i])) / \(CGFloat(sumTime)) * \(cellWidth)")
            print(CGFloat(self.searchModelLists[row].sectionTime[i])/CGFloat(sumTime)*cellWidth)
            widthList.append(CGFloat(self.searchModelLists[row].sectionTime[i])/CGFloat(sumTime)*cellWidth)
        }
        
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter
        }()
        let nowTime = Date().addingTimeInterval(TimeInterval(self.searchModelLists[row].totalTime*60))
        let time = dateFormatter.string(from: nowTime)
        let count = searchModelLists[row].seName.count
        
        let hour = searchModelLists[row].totalTime / 60
        let minute = searchModelLists[row].totalTime % 60
        
        let finalTime = hour == 0 ? "\(minute)???" : "\(hour)?????? \(minute)???"
        cell.time.text = finalTime
        cell.transferNum.text = "?????? \(searchModelLists[row].busTransitCount + searchModelLists[row].subwayTransitCount - 1)???"
        cell.walkTime.text = "?????? \(searchModelLists[row].totalWalk)M"
        cell.endTime.text = "\(time) ????????????"
        cell.icon.image = UIImage(named: "icRouteKind_\(SearchPathViewController.pathType)")
        
        // ?????? ??????
        for i in 0 ..< widthList.count {
            let time =  searchModelLists[row].sectionTime[i] > 2 ? "\(searchModelLists[row].sectionTime[i])???" : " "
            if self.searchModelLists[row].sectionTrafficType[i] == 1 {
                cell.addLineView(idx: i, lnCd: String(searchModelLists[row].subwayCodeLists[i]), length: widthList[i], time: time)
            } else if self.searchModelLists[row].sectionTrafficType[i] == 2 {
                cell.addLineView(idx: i, lnCd: "bus", length: widthList[i], time: time)
            } else {
                cell.addLineView(idx: i, lnCd: "walk", length: widthList[i], time: time)
            }
        }

        // ?????? ?????? ??????
        for i in 0 ..< count {
            print("searchModelLists[row].seName[\(i)] : \(searchModelLists[row].seName[i])")
            let (startStation, endStation, type, lane, startExit, endExit) = searchModelLists[row].seName[i]
            let station = type == "1" ? "\(startStation)" : "\(lane.components(separatedBy: "(")[0])???"
            var description = ""
            // ????????? ?????? ?????? ?????? ?????? ??????
            if i != 0 {
                description = type == "1" ? "??????" : "\(startStation) ??????"
            } else {
                description = type == "1" ? "\(startExit)??? ??????" : "\(startStation) ??????"
            }
            let icon = type == "1" ? "\(lane)" : "bus"
            cell.addDetailView(idx: i, station: station, description: description, icon: icon)
        }
        
        let (startStation, endStation, type, lane, startExit, endExit) = searchModelLists[row].seName[count - 1]
        let station = type == "1" ? "\(endStation)" : ""
        let description = type == "1" ? "\(endExit)??? ??????" : "\(endStation) ??????"
        let icon = type == "1" ? "\(lane)" : "end"
        cell.addDetailView(idx: count, station: station, description: description, icon: icon)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //MARK: ????????? ??? ?????? ??? ?????? ??????
        let row = indexPath.row
        let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchPathResultViewController") as! SearchPathResultViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        NotificationCenter.default.post(name: .returnMapObj, object: searchModelLists[row])
        
        var laneString = ""
        var stationString = ""
        var laneDetail = ""
        
        let pathData = searchModelLists[row].detailPathData
        let totalTime = self.searchModelLists[row].totalTime
        let totalDistance = self.searchModelLists[row].totalDistance
        let transferCount = self.searchModelLists[row].busTransitCount + self.searchModelLists[row].subwayTransitCount - 1
        let walkDistance = self.searchModelLists[row].totalWalk
        let count = pathData.count
        
        // ?????? ????????? ????????? ?????? ????????? ??????
        var stationCodeList = Array<String>()
        var stationNameList = Array<String>()
        var stationTypeList = Array<Int>()
        var stationLineNumberList = Array<String>()
        
        // ?????? ???????????? ????????? ?????? ????????? ??????
        var transferTypeData = Array<Int>()
        var distanceData = Array<Int>()
        var travelTimeData = Array<Int>()
        var lineNumberData = Array<String>()
        var isLowBusData = Array<Int>()
        
        for (idx, path) in pathData.enumerated() {
            print("path!! : \(path)")
            
            stationNameList += path.stationList
            stationCodeList += path.stationCodeList ?? []
            stationLineNumberList += []
            
            if path.laneCd == "bus" {
                laneString += "bus"
                stationString += "\(path.detail):\(path.stationCodeList ?? [])"
                laneDetail += "bus/\(path.detail):\(path.stationCodeList ?? [])"
                
                stationTypeList += Array(repeating: 1, count: path.stationList.count)
                stationLineNumberList += Array(repeating: path.detail, count: path.stationList.count)
                
                
                transferTypeData += [1]
                distanceData += [Int(path.distance) ?? 0]
                travelTimeData += [Int(path.time.components(separatedBy: "???")[0]) ?? 0]
                lineNumberData += [path.detail]
                isLowBusData += [0]
                
            } else if path.laneCd == "walk" {
                laneString += "walk"
                stationString += "walk"
                laneDetail += "walk"
                
                transferTypeData += [0]
                distanceData += [Int(path.distance) ?? 0]
                travelTimeData += [Int(path.time.components(separatedBy: "???")[0]) ?? 0]
                lineNumberData += [path.laneCd]
                isLowBusData += [0]
                
            } else {
                laneString += "subway"
                stationString += "\(path.laneCd)?????? \(path.stationList)"
                laneDetail += "subway/\(path.laneCd)??????:\(path.stationList)"
                
                stationTypeList += Array(repeating: 2, count: path.stationList.count)
                stationLineNumberList += Array(repeating: path.laneCd, count: path.stationList.count)
                
                transferTypeData += [2]
                distanceData += [Int(path.distance) ?? 0]
                travelTimeData += [Int(path.time.components(separatedBy: "???")[0]) ?? 0]
                lineNumberData += [path.laneCd]
                isLowBusData += [0]
            }
            if idx != count - 1 {
                laneString += " - "
                stationString += " - "
                laneDetail += " - "
            }
        }
        print(stationNameList)
        
        var pathDataDict: [String : Any] = [
            "stationCodeList" : stationCodeList,
            "stationNameList" : stationNameList,
            "stationTypeList" : stationTypeList,
            "stationLineNumberList" : stationLineNumberList
        ]
        
        var transferDataDict: [String: Any] = [
            "transferType": transferTypeData,
            "distance": distanceData,
            "travelTime": travelTimeData,
            "lineNumber": lineNumberData,
            "isLowBus": isLowBusData
        ]
        
        
        collectODData(laneDetail: laneDetail, totalDistance: totalDistance, totalTime: totalTime, transferCount: transferCount, walkDistance: walkDistance, pathDataDict: pathDataDict, transferDataDict: transferDataDict)
    }
    
    func collectODData(laneDetail: String, totalDistance: Int, totalTime: Int, transferCount: Int, walkDistance: Int, pathDataDict: [String: Any], transferDataDict: [String: Any]) {
        
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_ODDATA_SAVE
               
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.locale = Locale(identifier:"ko_KR")
        let search_date = dateformatter.string(from: Date())
        let param: [String : Any] = [
            "originName" : SearchViewController.startLocationString,
            "originLat" : SearchViewController.startLatLon.latitude,
            "originLon" : SearchViewController.startLatLon.longitude,
            "destinationName" : SearchViewController.endLocationString,
            "destinationLat" : SearchViewController.endLatLon.latitude,
            "destinationLon" : SearchViewController.endLatLon.longitude,
            "details" : laneDetail,
        
            "search_date" : search_date,
            "cell_num" : DataShare.shared().profileDao.cell_num,
            
            "total_distance" : totalDistance,
            "total_time" : totalTime,
            "transfer_count" : transferCount,
            "walk_distance" : walkDistance,
        ]
        
        AF.request(url, method: .post, parameters: param, encoding: URLEncoding.queryString).responseString { response in
            switch response.result {
            case .success(let data) :
                guard let idx = Int(data) else { return }
                print(idx)
                self.pathDataInsert(idx: idx, pathDataDict: pathDataDict)
                self.transferDataInsert(idx: idx, transferDataDict: transferDataDict)
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }
    
    func pathDataInsert(idx: Int, pathDataDict: [String: Any]) {
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_PATHDATA_SAVE
        var param: [String : Any] = pathDataDict
        param["idx"] = idx
        print("param : \(param)")
        
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseString { response in
            switch response.result {
            case .success(let data) :
                print("success : \(data)")
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }
    
    func transferDataInsert(idx: Int, transferDataDict: [String: Any]) {
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_TRANSFERDATA_SAVE
        var param: [String : Any] = transferDataDict
        param["idx"] = idx
        
        print("param : \(param)")
        
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseString { response in
            switch response.result {
            case .success(let data) :
                print("success : \(data)")
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }
    
}
// ?????????????????? ??????
extension SearchPathViewController {
    @objc func recieveLoactionData(_ notification: Notification) {
        print("recieveLoactionData - 111111")
    
        // ????????????????????? ?????? ????????? ????????? ?????? ??????
        let item = notification.object as? [String]
        guard let searchData = notification.object as? (startName: String, startLatLon: CLLocationCoordinate2D, endName: String, endLatLon: CLLocationCoordinate2D) else { return }
        print("searchData : \(searchData)")
        // ?????? ????????? ???????????? ??????
//        let (_, name, lat, lon) = (item![0],item![1],item![2],item![3])
        
        // type = ?????? ??????
        // 0 : ??????(?????????+??????) 1 : ?????????, 2 : ??????
        SearchPathViewController.pathType = 1
        SearchPathViewController.endLocation = searchData.endName
        
        startLabel.text = searchData.startName
        SearchViewController.startLocationString = searchData.startName
        SearchViewController.startLatLon = searchData.startLatLon
        
        endLabel.text = searchData.endName
        SearchViewController.endLocationString = searchData.endName
        SearchViewController.endLatLon = searchData.endLatLon
        
        searchPathData(searchPathType: myType)
    }
    
    func showToast(message : String, font: UIFont = UIFont(name: "NotoSansCJKkr-light", size: 12.0)!) {
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


// ODSay ?????? ?????? ??????
extension SearchPathViewController {
    func searchPathData (searchPathType: Int) {
        print("func SearchPathData searchPathType : \(searchPathType)")
        let sx = String(SearchViewController.startLatLon.longitude)
        let sy = String(SearchViewController.startLatLon.latitude)
        let ex = String(SearchViewController.endLatLon.longitude)
        let ey = String(SearchViewController.endLatLon.latitude)
        print("sx : \(sx), sy : \(sy), ex : \(ex), ey : \(ey)")
        print("SLoader start")
        SLoader.showLoading()
        
        self.searchModelLists.removeAll()

        ODsayService.sharedInst().requestSearchPubTransPath(sx, sy: sy, ex: ex, ey: ey, opt: 0, searchType: 0, searchPathType: Int32(searchPathType)) { (retCode: Int32, resultDict: [AnyHashable : Any]?) in
            if retCode == 200 {
                print("func SearchPathData2")
                if let s = resultDict?[AnyHashable("result")] {
                    let jsonData = JSON(s)
                    let path = jsonData["path"].arrayValue
                    print("==================================")
                    // ?????? ??? ?????????(?????? ???????????? ???) ????????? ???
                    // ?????? ??? ???????????? NULL or 1
                    print("json localSearch \(jsonData["localSearch"])")

                    for i in path {
                        let mapObj = i["info"]["mapObj"].stringValue
                        let totalWalk = i["info"]["totalWalk"].intValue
                        let totalTime = i["info"]["totalTime"].intValue
                        let busTransitCount = i["info"]["busTransitCount"].intValue
                        let subwayTransitCount = i["info"]["subwayTransitCount"].intValue
                        let totalDistance = i["info"]["totalDistance"].intValue
                                                
                        let data = SearchPathModel()
                        
                        print("kkk///////////////////////////////////////////")
                        
                        for j in i["subPath"].arrayValue {
                            var startExitY: Double = 0.0
                            var startExitX: Double = 0.0
                            var endExitY: Double = 0.0
                            var endExitX: Double = 0.0
                            var startName: String = ""
                            var endName: String = ""
                            var trafficType: String = ""
                            var busNo: String = ""
                            var busLocalBlID: String = ""
                            var subwayCode: String = ""
                            var startExitNo: String = ""
                            var endExitNo: String = ""
                            var sectionTime: String = ""
                            var stationCount: String = ""
                            var distance: String = ""
                            var stationNameList = [String]()
                            var stationCodeList = [String]()
                            var startID: String = ""
                            
                            if j["startExitX"].doubleValue != 0.0 {
                                startExitX = j["startExitX"].doubleValue
                            }
                            if j["startExitY"].doubleValue != 0.0 {
                                startExitY = j["startExitY"].doubleValue
                            }
                            if j["endExitX"].doubleValue != 0.0 {
                                endExitX = j["endExitX"].doubleValue
                            }
                            if j["endExitY"].doubleValue != 0.0 {
                                endExitY = j["endExitY"].doubleValue
                            }
                            if j["startName"].stringValue != "" {
                                startName = j["startName"].stringValue
                            }
                            if j["endName"].stringValue != "" {
                                endName = j["endName"].stringValue
                            }
                            if j["trafficType"].stringValue != "" {
                                trafficType = j["trafficType"].stringValue
                            }
                            if j["lane"][0]["busNo"].stringValue != "" {
                                busNo = j["lane"][0]["busNo"].stringValue
                            }
                            if j["lane"][0]["busLocalBlID"].stringValue != "" {
                                busLocalBlID = j["lane"][0]["busLocalBlID"].stringValue
                            }
                            if j["lane"][0]["subwayCode"].stringValue != "" {
                                subwayCode = j["lane"][0]["subwayCode"].stringValue
                            }
                            if j["startExitNo"].stringValue != "" {
                                startExitNo = j["startExitNo"].stringValue
                            }
                            if j["endExitNo"].stringValue != "" {
                                endExitNo = j["endExitNo"].stringValue
                            }
                            if j["sectionTime"].stringValue != "" {
                                sectionTime = j["sectionTime"].stringValue
                            }
                            if j["stationCount"].stringValue != "" {
                                stationCount = j["stationCount"].stringValue
                            }
                            if j["distance"].stringValue != "" {
                                distance = j["distance"].stringValue
                            }
                            if j["startID"].stringValue != "" {
                                startID = j["startID"].stringValue
                            }
                            subwayCode = SubwayUtils.shared().laneCdChange(laneCd: subwayCode)
                            data.exitLatLon.append((startExitLon: startExitX, startExitLat: startExitY, endExitLon: endExitX, endExitLat: endExitY, busNo: busNo))
                            if (startName, endName) != ("","") {
                                if busNo == "" {
                                    data.seName.append((startName, endName, trafficType, subwayCode, startExitNo, endExitNo))
                                } else {
                                    data.seName.append((startName, endName, trafficType, busNo, "", ""))
                                }
                            }
                            for k in j["passStopList"]["stations"].arrayValue {
                                stationNameList.append(k["stationName"].stringValue)
                                if k["localStationID"].stringValue != "" {
                                    stationCodeList.append(k["localStationID"].stringValue)
                                } else if k["stationID"].stringValue != "" {
                                    stationCodeList.append(k["stationID"].stringValue)
                                }
                                
                            }
                            if trafficType == "1" { // ?????????
                                print("wwwww\(j)")
                                data.detailPathData.append(
                                    SearchPathData(laneCd: subwayCode, title: startName, detail: "\(stationNameList[1])??? ??????", time: "\(sectionTime)???", move: "\(stationCount)??? ??? ??????", stationList: stationNameList, stationCodeList: stationCodeList, startExitNo: startExitNo, endExitNo: endExitNo, stinCd: startID, distance: distance)
                                )
                            } else if trafficType == "2" { // ??????
                                print("wwwww\(j)")
                                data.detailPathData.append(
                                    SearchPathData(laneCd: "bus", title: startName, detail: "\(busNo)???", time: "\(sectionTime)???", move: "\(stationCount)??? ??? ??????", stationList: stationNameList, stationCodeList: stationCodeList, busLocalBlID: busLocalBlID, distance: distance)
                                )
                            } else { // ??????
                                print("wwwww\(j)")
                                if j["distance"].stringValue != "0" {
                                    data.detailPathData.append(
                                        SearchPathData(laneCd: "walk", title: "????????????", detail: "", time: sectionTime, move: distance, stationList: stationNameList, distance: distance)
                                    )
                                }
                            }
                        }
                        for s in i["subPath"] {
                            guard let idx = Int(s.0) else { return }
                            
                            print("sss_i['subPath'] idx : \(idx)")
                            print("sss_i['subPath'] s : \(s)")
                            
                            if idx > 0 {
                                data.sectionTime.append(0)
                                data.sectionTrafficType.append(0)
                                data.subwayCodeLists.append(0)
                            }
                            data.sectionTime[idx] = s.1["sectionTime"].intValue
                            data.sectionTrafficType[idx] = s.1["trafficType"].intValue
                            data.subwayCodeLists[idx] = s.1["lane"][0]["subwayCode"].intValue
                        }
                                                
                        data.mapObj = mapObj
                        data.totalTime = totalTime
                        data.totalWalk = totalWalk
                        data.busTransitCount = busTransitCount
                        data.subwayTransitCount = subwayTransitCount
                        data.totalDistance = totalDistance
                        
                        self.searchModelLists.append(data)
                    }
                    
                    
                    if self.searchModelLists.count == 0 {
                        self.showToast(message: "??????????????? ????????????.")
                    }
                }
            } else {
                guard let result = resultDict?[AnyHashable("error")] else { return }
                let jsonResult = JSON(result)
                print(result)
                print(jsonResult)
                let msg = jsonResult[0]["msg"].stringValue
                self.showToast(message: msg)
            }
            print("SLoader end")
            CATransaction.begin()
            self.tableView.reloadData()
            CATransaction.commit()
            SLoader.hide()
        }
    }
}
