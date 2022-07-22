//
//  SubwayViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit
import Alamofire

class SubwayViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var subwayLaneList: [SubwayLane]?
    var subwayLineList = [SubwayModelBody]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(SubwayCollectionViewCell.self, forCellWithReuseIdentifier: "SubwayCollectionViewCell")
        subwayLaneList = DataShare.shared().subwayLaneList
        
        NotificationCenter.default.addObserver(self, selector: #selector(subwaySearchByName(_:)), name: .subwaySearchByName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        let firstIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .right)
        collectionView(self.collectionView, didSelectItemAt: firstIndexPath)
    }
    
    @IBAction func tapSubwaySearchStation(_ sender: Any) {
        let vc = UIStoryboard(name: "Subway", bundle: nil).instantiateViewController(withIdentifier: "SubwaySearchViewController") as! SubwaySearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func subwaySearchByName(_ notification: Notification) {
        guard let data = notification.object as? [SubwayModelBody] else { return }
        print("subwaySearchByName : \(data)")
        subwayLineList = data

    }


}

extension SubwayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subwayLaneList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = indexPath.row
        return SubwayCollectionViewCell.fittingSize(availableHeight: 32, name: subwayLaneList?[row].LN_NM)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubwayCollectionViewCell", for: indexPath) as! SubwayCollectionViewCell
        cell.setTitle(title: subwayLaneList?[row].LN_NM)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let lnCd = subwayLaneList?[row].LN_CD
        
        print("lnCd = \(lnCd)")
        
        subwayRouteInfoCall(lnCd: lnCd ?? "")
    }
    
    
}

extension SubwayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subwayLineList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubwayTableViewCell", for: indexPath) as! SubwayTableViewCell
        let row = indexPath.row
        cell.stationIcon.image = UIImage(named: "circle_line_\(subwayLineList[row].lnCd)_16")
        cell.titleLabel.text = subwayLineList[row].stinNm
        
        cell.phoneCallBtn.tag = row
        cell.subwayFavoriteBtn.tag = row
        
        cell.subwayFavoriteBtn.addTarget(self, action: #selector(tapFavoriteBtn), for: .touchUpInside)
        cell.phoneCallBtn.addTarget(self, action: #selector(tapPhoneCallBtn), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "Info", bundle: nil).instantiateViewController(withIdentifier: "SubwayStationInfoViewController") as! SubwayStationInfoViewController
        let row = indexPath.row

        self.navigationController?.pushViewController(vc, animated: true)
    
        vc.subwayLineInfo = subwayLineList[row]
        NotificationCenter.default.post(name: .receiveSubwayInfo, object: subwayLineList[row])
    }
    
    @objc func tapFavoriteBtn(_ sender: UIButton) {
        // MARK: 즐겨찾기 추가 기능 구현 예정
        sender.isSelected = !sender.isSelected
        print(subwayLineList[sender.tag])
        
    }
    
    
    @objc func tapPhoneCallBtn(_ sender: UIButton) {
        print(subwayLineList[sender.tag])
        let stinCd = subwayLineList[sender.tag].stinCd
        let routCd = subwayLineList[sender.tag].routCd
        let stinNm = subwayLineList[sender.tag].stinNm
        callStation(stinCd: stinCd, routCd: routCd, stinNm: stinNm)
    }
}

// MARK: API 모음
extension SubwayViewController {
    // 도시철도 전체노선정보 API
    func subwayRouteInfoCall(lnCd: String) {
        print("도시철도 전체노선정보 API")
        subwayLineList.removeAll()
        let para : [String: Any] = [
            "serviceKey": "$2a$10$o/DL6MPbsjRS2llxGiiOH.wSfVCQ12fX35EXR39AlcGWAtztWle0O",
            "format": "json",
            "lnCd": lnCd,
            "mreaWideCd":"01"
        ]
        AF.request("http://openapi.kric.go.kr/openapi/trainUseInfo/subwayRouteInfo",parameters: para, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(SubwayModel.self, from: jsonData)
                    print("data = \(getInstanceData)")
                    getInstanceData.body?.filter {
                        $0.lnCd == lnCd
                    }
                    self.subwayLineList = getInstanceData.body?.filter { $0.lnCd == lnCd } ?? [SubwayModelBody]()
                } catch {
                    print(error.localizedDescription)
                }
                
                /*
                for i in jsonBody {
//                    print(i.1)
                    if i.1["routCd"].stringValue == lnCd {
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
                print(count)
                
                self.sortSubwayLineList(rule: self.sortRuleIndex)
                self.tableView.reloadData()
                */
//                break
            case .failure(let error):
                print("error: \(error.localizedDescription)")
//                break
            }
        }
    }
    
    func callStation(stinCd: String, routCd: String, stinNm: String) {
        let para : [String: Any] = [
            "stinCd": stinCd,
            "routCd": routCd,
            "stinNm": stinNm
        ]
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_STATION_PHONE
        AF.request(url, method: .post, parameters: para, encoding: URLEncoding.queryString).responseString { response in
            switch response.result {
            case .success(let data) :
                print("data : \(data)")
                if data != "null" {
                    UsefulUtils.callTo(phoneNumber: data)
                }
                //MARK: 전화번호가 없을 경우 어떡하징
            case .failure(let error):
                print("error : \(error.localizedDescription)")
            }
        }
    }
}
