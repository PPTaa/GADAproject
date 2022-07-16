//
//  FloatingViewController.swift
//  HANDYCAB_RE
//
//  Created by leejungchul on 2021/06/08.
//

import UIKit
import FloatingPanel
import Alamofire
import SwiftyJSON
import SnapKit

class FloatingViewController : UIViewController {
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var layoutView: UIView!
    @IBOutlet weak var layoutTop: NSLayoutConstraint!
    @IBOutlet weak var layoutBottom: NSLayoutConstraint!
    @IBOutlet weak var boundaryView: UIView!
    @IBOutlet weak var emptyView: UIView!
    
    // 경로 아이콘
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "icRouteKind_1")
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    // 소요 시간 표기
    let totalTime: UILabel = {
        let text = UILabel()
        text.font = UIFont(name: "Montserrat-SemiBold", size: 24)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 환승 횟수 표기
    let transferNum: UILabel = {
        let text = UILabel()
        text.font = UIFont(name: "NotoSansCJKkr-Regular", size: 12)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 사이 선
    let line1: UIView = {
        let line = UIView()
        line.backgroundColor = .black
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    // 보행 시간 표기
    let walkTime: UILabel = {
        let text = UILabel()
        text.font = UIFont(name: "NotoSansCJKkr-Regular", size: 12)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 사이 선
    let line2: UIView = {
        let line = UIView()
        line.backgroundColor = .black
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    // 도착 예상 시간 표기
    let endTime: UILabel = {
        let text = UILabel()
        text.font = UIFont(name: "Montserrat-Regular", size: 12)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 시간 표기 바 표출 뷰
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 기본 라인
    let basicLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "color-gray-30")
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    var searchModel: SearchPathModel!
    var subwayLineList = [SubwayLineModel]()
    var transferData = TransferData(chthTgtLn: "", chtnNextStinCd: "", railOprIsttCd: "", lnCd: "", stinCd: "", prevStinCd: "", stinNm: "")
    
    var safeAreaHeight: CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContainerView()
        setupTableView()
        
        if (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! > CGFloat(0.0) {
            safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        } else {
            safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        }
        
        layoutTop.constant += safeAreaHeight / 3
        layoutBottom.constant += safeAreaHeight * 2 / 3
        
        icon.image = UIImage(named: "icRouteKind_\(SearchPathViewController.pathType)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(recieveMapObjData(_:)), name: .returnMapObj, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .returnMapObj, object: nil)
    }
    
    fileprivate func setupContainerView() {
        print("setupContainerView()")
        layoutView.addSubview(icon)
        icon.snp.makeConstraints {
            $0.leading.top.equalTo(layoutView)
        }
        
        layoutView.addSubview(totalTime)
        totalTime.snp.makeConstraints {
            $0.leading.equalTo(icon)
            $0.top.equalTo(icon.snp.bottom).offset(10)
        }
        
        layoutView.addSubview(transferNum)
        transferNum.snp.makeConstraints {
            $0.leading.equalTo(totalTime.snp.trailing).offset(8)
            $0.bottom.equalTo(totalTime).offset(-3)
        }
        
        layoutView.addSubview(line1)
        line1.snp.makeConstraints {
            $0.leading.equalTo(transferNum.snp.trailing).offset(5)
            $0.top.equalTo(transferNum).offset(3)
            $0.bottom.equalTo(transferNum).offset(-3)
            $0.width.equalTo(1)
        }
        
        layoutView.addSubview(walkTime)
        walkTime.snp.makeConstraints {
            $0.leading.equalTo(line1.snp.trailing).offset(5)
            $0.bottom.equalTo(totalTime).offset(-3)
        }
        
        layoutView.addSubview(line2)
        
        line2.snp.makeConstraints {
            $0.leading.equalTo(walkTime.snp.trailing).offset(5)
            $0.top.bottom.equalTo(line1)
            $0.width.equalTo(1)
        }
        
        layoutView.addSubview(endTime)
        endTime.snp.makeConstraints {
            $0.leading.equalTo(line2.snp.trailing).offset(5)
            $0.bottom.equalTo(totalTime).offset(-3)
        }
        
        layoutView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.equalTo(totalTime.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalTo(layoutView)
        }
        
        containerView.addSubview(basicLine)
        basicLine.snp.makeConstraints {
            $0.leading.trailing.equalTo(containerView)
            $0.top.equalTo(containerView).offset(17.4)
            $0.height.equalTo(4)
        }
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(emptyView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(DetailPathCell.self, forCellReuseIdentifier: "DetailPathCell")
        tableView.register(DetailWalkPathCell.self, forCellReuseIdentifier: "DetailWalkPathCell")
        tableView.register(DetailEndPathCell.self, forCellReuseIdentifier: "DetailEndPathCell")
    }
    
    var data = [SearchPathData]()
    
    var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
}

extension FloatingViewController {
    @objc func recieveMapObjData(_ notification: Notification) {
    
        // 노티피케이션을 통해 리스트 형태로 정보 받음
        let item = notification.object as! SearchPathModel
        print("noti-----", item)
        print("noti-----", item.seName)
        print("noti-----", item.totalTime)
        print("noti-----", item.detailPathData)
        print("noti-----", item.busID)
        print("noti-----", item.busNo)
        print("startLabel, \(SearchViewController.startLocationString)")
        print("startLabel, \(SearchViewController.endLocationString)")
        for i in item.detailPathData {
            print("ooooo\(i)")
            data.append(i)
        }
        
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter
        }()
        let nowTime = Date().addingTimeInterval(TimeInterval(item.totalTime*60))
        let time = dateFormatter.string(from: nowTime)

        
        let sumTime = item.sectionTime.reduce(0, +)
        let cellWidth = self.view.frame.size.width - 60
        var widthList = [CGFloat]()
        for i in 0 ..< item.sectionTime.count {
            widthList.append(CGFloat(item.sectionTime[i])/CGFloat(sumTime)*cellWidth)
        }
        let hour = item.totalTime / 60
        let minute = item.totalTime % 60
        
        let finalTime = hour == 0 ? "\(minute)분" : "\(hour)시간 \(minute)분"
        totalTime.text = finalTime
        transferNum.text = "환승 \(item.busTransitCount + item.subwayTransitCount - 1)회"
        walkTime.text = "보행 \(item.totalWalk)M"
        endTime.text = "\(time) 도착예정"
        icon.image = UIImage(named: "icRouteKind_\(SearchPathViewController.pathType)")
        
        // 라인 추가
        for i in 0 ..< widthList.count {
            print("idx : \(i)")
            print("searchModelLists[row].subwayCodeLists[i] : \(item.subwayCodeLists[i])")
            print("searchModelLists[row].sectionTrafficType[i] : \(item.sectionTrafficType[i])")
            print("length : \(widthList[i])")
            let time =  item.sectionTime[i] > 2 ? "\(item.sectionTime[i])분" : " "
            if item.sectionTrafficType[i] == 1 {
                addLineView(idx: i, lnCd: String(item.subwayCodeLists[i]), length: widthList[i], time: time)
            } else if item.sectionTrafficType[i] == 2 {
                addLineView(idx: i, lnCd: "bus", length: widthList[i], time: time)
            } else {
                addLineView(idx: i, lnCd: "walk", length: widthList[i], time: time)
            }
        }
    }
    
    func addLineView(idx: Int, lnCd: String, length: CGFloat, time: String) {
        
        let lineView = UIView()
        let lineLabel = UILabel()
    
        lineLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 9.5)
        lineLabel.text = time
        lineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        print("run addLineView \(idx), \(lnCd), \(length)")
        
        if lnCd == "bus" {
            lineView.backgroundColor = .black
        } else if lnCd == "walk" {
            lineView.backgroundColor = UIColor(named: "color-gray-30")
        } else {
            lineView.backgroundColor = UIColor(named: "color-\(lnCd)")
        }
        
        lineView.layer.cornerRadius = 2
        lineView.widthAnchor.constraint(equalToConstant: length).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        if idx == 0 {
            containerView.addSubview(lineLabel)
            containerView.addSubview(lineView)
            lineLabel.snp.makeConstraints {
                $0.top.equalTo(containerView)
                $0.centerX.equalTo(lineView)
            }
            lineView.snp.makeConstraints {
                $0.top.equalTo(lineLabel.snp.bottom).offset(3)
                $0.leading.equalTo(containerView)
            }
        } else {
            let lastView = containerView.subviews.last
            
            containerView.addSubview(lineLabel)
            containerView.addSubview(lineView)
            lineLabel.snp.makeConstraints {
                $0.top.equalTo(containerView)
                $0.centerX.equalTo(lineView)
            }
            lineView.snp.makeConstraints {
                $0.centerY.equalTo(lastView!)
                $0.leading.equalTo(lastView!.snp.trailing)
            }
        }
    }
}


extension FloatingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        if selectedIndex == indexPath {
            if !data[row].isSelected {
                return 84
            } else {
                return CGFloat(84 + Double(data[row].stationList.count * 18))
            }
        }
        return 84
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView() 
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPathCell") as! DetailPathCell
        let cellWalk = tableView.dequeueReusableCell(withIdentifier: "DetailWalkPathCell") as! DetailWalkPathCell
        let cellEnd = tableView.dequeueReusableCell(withIdentifier: "DetailEndPathCell") as! DetailEndPathCell
        
        
        if row == data.count {
            cellEnd.data = [SearchViewController.startLocationString, SearchPathViewController.endLocation]
            cellEnd.selectionStyle = .none
            return cellEnd
        }
        print("cell --- data[\(row)] : ",data[row])
        
        if data[row].laneCd == "walk" {
            cellWalk.data = data[row]
            if row == 0 {
                if data[1].laneCd == "bus" {
                    cellWalk.startWalk = [SearchViewController.startLocationString, "\(data[1].title) 정류장"]
                } else {
                    cellWalk.startWalk = [SearchViewController.startLocationString, "\(data[1].title) \(data[1].startExitNo ?? "")번 출구"]
                }
            } else if row > 0 {
                // 하차역 상세정보를 얻기 위한 재구성
                data[row].routeEndData = [data[row-1].laneCd, data[row-1].stationList.last ?? ""]
                print("walk cell --- data[\(row)] : ", data[row])
                
                cellWalk.postData = data[row-1]
                cellWalk.endTransfer = [data[row-1].endExitNo ?? "", data[row-1].laneCd]
                cellWalk.stationInfoBtn.laneCd = "subway"
                cellWalk.stationInfoBtn.tag = row
                cellWalk.stationInfoBtn.isTrue = true
                
                cellWalk.stationInfoBtn.addTarget(self, action: #selector(stationInfoBtnClick), for: .touchUpInside)
            }
            cellWalk.selectionStyle = .none
            tableView.reloadRows(at: [indexPath], with: .none)
            return cellWalk
        } else {
            cell.data = data[row]
            if row > 0 {
                cell.postData = data[row-1]
            }
            if cell.stationInfoBtn.isTransfer ?? false {
                print("cell.stationInfoBtn.isTransfer : \(cell.stationInfoBtn.isTransfer)")
                cell.stationInfoBtn.nextStinNm = data[row].stationList[1]
                print(cell.stationInfoBtn.nextStinNm)
            }
            
            cell.stationInfoBtn.tag = row
            cell.stationInfoBtn.isTrue = false
            cell.stationInfoBtn.addTarget(self, action: #selector(stationInfoBtnClick), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        print(indexPath.row)
        print(data.count)
         
        if indexPath.row == data.count {
            return
        }
        
        for i in 0 ..< data.count {
            if i == selectedIndex.row {
                data[i].isSelected = !data[i].isSelected
            } else {
                data[i].isSelected = false
            }
        }
        if data[indexPath.row].laneCd == "walk" {
            return
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: [selectedIndex], with: .none)
        tableView.endUpdates()
        
    }
    
    @objc func stationInfoBtnClick(sender: CustomButton) {
        print("stationInfoBtn Click laneCd : \(sender.laneCd)") // 버튼별 대중교통 종류
        print("stationInfoBtn Click tag : \(sender.tag)") // 누르는 버튼의 인덱스
        print("stationInfoBtn Click isTrue : \(sender.isTrue)") // 도보경로인지 판단
        print("stationInfoBtn Click isTransfer : \(sender.isTransfer)") // 환승경로인지 판다
        print("stationInfoBtn Click data : \(data[sender.tag])") // 데이터 확인용
         
        let laneCd = data[sender.tag].laneCd
        let lnCd = SubwayUtils.shared().laneCdChange(laneCd: laneCd)
        if sender.laneCd == "bus" {
            guard let busLocalBlID = data[sender.tag].busLocalBlID else { return }
            print("busbusbus", data[sender.tag])
            let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "BusInfoViewController") as! BusInfoViewController
            vc.busLocalBlID = busLocalBlID
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            
        } else if sender.laneCd == "subway"{
            if sender.isTransfer ?? false {
                let prevLaneCd = data[sender.tag - 1].laneCd
                let prevlnCd = SubwayUtils.shared().laneCdChange(laneCd: prevLaneCd)
    //            "railOprIsttCd": "S1", // 철도운영기관코드
    //            "lnCd": "3", // 환승시작 선코드
    //            "stinCd": "322", // 환승시작 역코드
                
    //            "chthTgtLn": "", // 환승이후 선코드
    //            "chtnNextStinCd": "", // 환승이후 이전역코드
    //            "prevStinCd": "323", // 환승이후 다음역코드
                var nextStinNm = sender.nextStinNm
                if nextStinNm == "대림" {
                    nextStinNm = "대림(구로구청)"
                }
                // 환승 시작 선코드, 역코드, 철도운영기관코드
                subwayRouteInfoCall(lnCd: prevlnCd, row: sender.tag, isWalk: sender.isTrue ?? false, isTransfer: true, isFirst: true)
                // 환승 이후 선코드, 이전역코드, 다음역코드
                usleep(100000)
                // 다음역
                subwayRouteInfoCall(lnCd: lnCd, row: sender.tag, isWalk: sender.isTrue ?? false, isTransfer: true, nextStinNm: nextStinNm ?? "", nowStinNm: data[sender.tag].title)
                
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "SearchTransferViewController") as! SearchTransferViewController
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            } else {
                // 하차역 정보 표시를 위한 분기처리
                if data[sender.tag].routeEndData != nil {
                    let endLaneCd = data[sender.tag].routeEndData![0]
                    let endLnCd = SubwayUtils.shared().laneCdChange(laneCd: endLaneCd)
                    print("endLnCd : \(endLnCd)")
                    print("endLaneCd : \(endLaneCd)")
                    subwayRouteInfoCall(lnCd: endLnCd, row: sender.tag, isWalk: false, nowStinNm: data[sender.tag].routeEndData![1])
                } else {
                    subwayRouteInfoCall(lnCd: lnCd, row: sender.tag, isWalk: sender.isTrue ?? false, nowStinNm: data[sender.tag].title)
                }
                let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "SubwayInfoViewController") as! SubwayInfoViewController
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }
        }
    }
}

extension FloatingViewController {
    
    // 도시철도 전체노선정보 API
    func subwayRouteInfoCall(lnCd: String, row: Int, isWalk: Bool, isTransfer: Bool = false, isFirst: Bool = false, nextStinNm: String = "", nowStinNm: String = "") {
        print("도시철도 전체노선정보 API")
        subwayLineList.removeAll()
        
        let para : Parameters = [
            "serviceKey": "$2a$10$o/DL6MPbsjRS2llxGiiOH.wSfVCQ12fX35EXR39AlcGWAtztWle0O",
            "format": "json",
            "lnCd": lnCd,
            "mreaWideCd":"01"
        ]
        AF.request("http://openapi.kric.go.kr/openapi/trainUseInfo/subwayRouteInfo",parameters: para, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                let jsonBody = JSON(data)["body"]
                var nowCount = 0
                print("subwayRouteInfoCall", jsonBody)
                self.subwayLineList.removeAll()
                
                if jsonBody.isEmpty {
                    print("aaavvv")
                    if isTransfer {
                        let dataSet = TransferData(chthTgtLn: "", chtnNextStinCd: "", railOprIsttCd: "", lnCd: "", stinCd: "", prevStinCd: "", stinNm: nowStinNm)
                        
                        NotificationCenter.default.post(name: .receiveTransferInfo, object: dataSet)
                    } else {
                        var dataSet = SubwayLineModel()
                        dataSet.stinNm = nowStinNm
                        NotificationCenter.default.post(name: .receiveSubwayInfo, object: dataSet)
                    }
                    return
                }
                
                for i in jsonBody {
                    if i.1["routCd"].stringValue == "\(lnCd)" {
                        var subwayLine = SubwayLineModel()
                        subwayLine.lnCd = i.1["lnCd"].stringValue
                        subwayLine.routCd = i.1["routCd"].stringValue
                        subwayLine.stinCd = i.1["stinCd"].stringValue
                        subwayLine.stinNm = i.1["stinNm"].stringValue
                        subwayLine.railOprIsttCd = i.1["railOprIsttCd"].stringValue
                        subwayLine.stinConsOrdr = i.1["stinConsOrdr"].stringValue
                        subwayLine.routNm = i.1["routNm"].stringValue
                        subwayLine.mreaWideCd = i.1["mreaWideCd"].stringValue
                        self.subwayLineList.append(subwayLine)
                    }
                }
                let count = self.subwayLineList.count
                for (idx, val) in self.subwayLineList.enumerated() {
                    if idx == 0 {
                        val.nextStinCd = self.subwayLineList[idx+1].stinCd
                    } else if idx == count-1 {
                        val.prevStinCd = self.subwayLineList[idx-1].stinCd
                    } else {
                        val.nextStinCd = self.subwayLineList[idx+1].stinCd
                        val.prevStinCd = self.subwayLineList[idx-1].stinCd
                    }
                }
                let exceptStationList = ["주안", "부평", "가정", "동두천", "도봉", "인천", "오산", "과천", "미아", "동대문", "왕십리", "석촌"]
                let lastIdx = self.subwayLineList.count - 1
                for (idx, i) in self.subwayLineList.enumerated() {
                    nowCount += 1
                    let prevIdx = (idx == 0 ? lastIdx : idx - 1)
                    let nextIdx = (idx == lastIdx ? 0 : idx + 1)
                    if isTransfer { // 환승인경우
                        if isFirst { // 첫번째 역인 경우
                            // "railOprIsttCd": "S1", 철도운영기관코드
                            // "lnCd": "3",           환승시작 선코드
                            // "stinCd": "322",       환승시작 역코드
                            if exceptStationList.contains(self.data[row].title)  { // 제외 리스트에 포함된 경우
                                if i.stinNm == self.data[row].title {
                                    self.transferData.stinNm = i.stinNm
                                    self.transferData.railOprIsttCd = i.railOprIsttCd
                                    self.transferData.lnCd = i.lnCd
                                    self.transferData.stinCd = i.stinCd
                                    print("ppppppp",self.transferData)
                                    break
                                }
                            } else { // 제외 리스트에 포함된 경우
                                if self.data[row].title.contains(i.stinNm) {
                                    self.transferData.stinNm = i.stinNm
                                    self.transferData.railOprIsttCd = i.railOprIsttCd
                                    self.transferData.lnCd = i.lnCd
                                    self.transferData.stinCd = i.stinCd
                                    print("ppppppp",self.transferData)
                                    break
                                }
                                if i.stinNm.contains(self.data[row].title) {
                                    self.transferData.stinNm = i.stinNm
                                    self.transferData.railOprIsttCd = i.railOprIsttCd
                                    self.transferData.lnCd = i.lnCd
                                    self.transferData.stinCd = i.stinCd
                                    print("ppppppp",self.transferData)
                                    break
                                }
                            }
                        } else {
                            // "chthTgtLn": "", // 환승이후 선코드
                            // "chtnNextStinCd": "", // 환승이후 이전역코드
                            // "prevStinCd": "323", // 환승이후 다음역코드
                            if exceptStationList.contains(self.data[row].title)  {
                                if i.stinNm == self.data[row].title {
                                    self.transferData.stinNm = i.stinNm
                                    
                                    print("i.stinNm == self.data[row].title nextStinNm : \(nextStinNm)")
                                    var nextStinCd = ""
                                    if self.subwayLineList[prevIdx].stinNm.contains(nextStinNm) {
                                        print("self.subwayLineList[idx-1].stinNm.contains(nextStinNm)")
                                        print(self.subwayLineList[prevIdx].stinCd)
                                        nextStinCd = self.subwayLineList[prevIdx].stinCd
                                    }
                                    if self.subwayLineList[nextIdx].stinNm.contains(nextStinNm) {
                                        print("self.subwayLineList[idx+1].stinNm.contains(nextStinNm)")
                                        print(self.subwayLineList[nextIdx].stinCd)
                                        nextStinCd = self.subwayLineList[nextIdx].stinCd
                                    }
                                    
                                    let temp = self.stinCd(stinCd: i.stinCd, nextStinCd: nextStinCd)
                                    
                                    self.transferData.chthTgtLn = i.lnCd
                                    self.transferData.chtnNextStinCd = temp.1
                                    self.transferData.prevStinCd = temp.0
                                    print("qqqqqqq",self.transferData)
                                    NotificationCenter.default.post(name: .receiveTransferInfo, object: self.transferData)
                                    break
                                }
                            } else {
                                if self.data[row].title.contains(i.stinNm) {
                                    self.transferData.stinNm = i.stinNm
                                    
                                    print("self.data[row].title.contains(i.stinNm) nextStinNm : \(nextStinNm)")
                                    
                                    var nextStinCd = ""
                                    if self.subwayLineList[prevIdx].stinNm.contains(nextStinNm) {
                                        print("self.subwayLineList[idx-1].stinNm.contains(nextStinNm)")
                                        print(self.subwayLineList[prevIdx].stinCd)
                                        nextStinCd = self.subwayLineList[prevIdx].stinCd
                                    }
                                    if self.subwayLineList[nextIdx].stinNm.contains(nextStinNm) {
                                        print("self.subwayLineList[idx+1].stinNm.contains(nextStinNm)")
                                        print(self.subwayLineList[nextIdx].stinCd)
                                        nextStinCd = self.subwayLineList[nextIdx].stinCd
                                    }
                                    
                                    let temp = self.stinCd(stinCd: i.stinCd, nextStinCd: nextStinCd)
                                    
                                    self.transferData.chthTgtLn = i.lnCd
                                    self.transferData.chtnNextStinCd = temp.1
                                    self.transferData.prevStinCd = temp.0
                                    print("qqqqqqq",self.transferData)
                                    NotificationCenter.default.post(name: .receiveTransferInfo, object: self.transferData)
                                    break
                                }
                                if i.stinNm.contains(self.data[row].title) {
                                    self.transferData.stinNm = i.stinNm
                                    
                                    print("i.stinNm.contains(self.data[row].title) nextStinNm : \(nextStinNm)")
                                    var nextStinCd = ""
                                    if self.subwayLineList[prevIdx].stinNm.contains(nextStinNm) {
                                        print("self.subwayLineList[idx-1].stinNm.contains(nextStinNm)")
                                        print(self.subwayLineList[prevIdx].stinCd)
                                        nextStinCd = self.subwayLineList[prevIdx].stinCd
                                    }
                                    if self.subwayLineList[nextIdx].stinNm.contains(nextStinNm) {
                                        print("self.subwayLineList[idx+1].stinNm.contains(nextStinNm)")
                                        print(self.subwayLineList[nextIdx].stinCd)
                                        nextStinCd = self.subwayLineList[nextIdx].stinCd
                                    }
                                    
                                    let temp = self.stinCd(stinCd: i.stinCd, nextStinCd: nextStinCd)
                                    
                                    self.transferData.chthTgtLn = i.lnCd
                                    self.transferData.chtnNextStinCd = temp.1
                                    self.transferData.prevStinCd = temp.0
                                    print("qqqqqqq",self.transferData)
                                    NotificationCenter.default.post(name: .receiveTransferInfo, object: self.transferData)
                                    break
                                }
                            }
                        }
                    }
                    
                    if isWalk { // 도보의 경우
                        if exceptStationList.contains(self.data[row].stationList[self.data[row].stationList.count - 1])  {
                            if i.stinNm == self.data[row].stationList[self.data[row].stationList.count - 1] {
                                NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                break
                            }
                        } else {
                            if self.data[row].stationList[self.data[row].stationList.count - 1].contains(i.stinNm) {
                                NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                break
                            }
                            if i.stinNm.contains(self.data[row].stationList[self.data[row].stationList.count - 1]) {
                                NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                break
                            }
                        }
                        
                    } else { // 환승이 아닌 경우
                        print("c", i)
                        print("\(self.data[row].title)")
                        print("\(i.lnCd), \(i.stinNm), \(i.stinCd)")
                        // 하차역인 경우
                        if self.data[row].title == "현재위치" {
                            if exceptStationList.contains(self.data[row].routeEndData![1])  {
                                if i.stinNm == self.data[row].routeEndData![1] {
                                    NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                    break
                                }
                            } else {
                                if self.data[row].routeEndData![1].contains(i.stinNm) {
                                    NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                    break
                                }
                                if i.stinNm.contains(self.data[row].routeEndData![1]) {
                                    NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                    break
                                }
                            }
                        } else { // 하차역이 아닌경우
                            if exceptStationList.contains(self.data[row].title)  {
                                if i.stinNm == self.data[row].title {
                                    NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                    break
                                }
                            } else {
                                if self.data[row].title.contains(i.stinNm) {
                                    NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                    break
                                }
                                if i.stinNm.contains(self.data[row].title) {
                                    NotificationCenter.default.post(name: .receiveSubwayInfo, object: i)
                                    break
                                }
                            }
                        }
                    }
                }
                break
            case .failure(let error):
                print("error: \(error)")
                break
            }
        }
    }
    
    func stinCd(stinCd: String, nextStinCd: String = "") -> (String, String) {
        
        if stinCd == "201" {
            if nextStinCd == "202" {
                return ("243", "202")
            } else {
                return ("202", "243")
            }
        }
        
        let stinCdList = Array(stinCd)
        let nextStinCdList = Array(nextStinCd)
        if stinCdList == [] || nextStinCdList == [] {
            return ("", "")
        }
        print("stinCd Func ",stinCdList, nextStinCdList)

        var nowFirst = ""
        var now = ""
        var next = ""
        
        for i in 0 ..< stinCdList.count {
            if i == 0 {
                nowFirst = String(stinCdList[i])
            } else {
                now += String(stinCdList[i])
                next += String(nextStinCdList[i])
            }
        }
        var prevStinCd = ""
        
        if Int(now) ?? 0 < Int(next) ?? 0 {
            let resultInt = (Int(now) ?? 0) - 1
            prevStinCd = nowFirst + String(format: "%02d", resultInt)
        } else {
            let resultInt = (Int(now) ?? 0) + 1
            prevStinCd = nowFirst + String(format: "%02d", resultInt)
        }
        
        return (prevStinCd, nextStinCd)
    }
}

public struct TransferData {
    var chthTgtLn: String // 환승대상선
    var chtnNextStinCd: String // 환승이후역코드
    var railOprIsttCd: String // 철도운영기관코드
    var lnCd: String // 선코드
    var stinCd: String // 역코드
    var prevStinCd: String // 이전역코드
    var stinNm: String // 역이름
}


class PathFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 70.0, edge: .top, referenceGuide: .safeArea),
//            .half: FloatingPanelLayoutAnchor(absoluteInset: 165.0, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 165.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
}
