//
//  SubwaySearchViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/11.
//

import UIKit
import Alamofire
import SwiftUI

class SubwaySearchViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var subwayLineList = [SubwayModelBody]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.inputDefault?.cgColor
        searchTextField.layer.cornerRadius = 2
        searchTextField.addLeftPadding()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    @IBAction func tapBackBtn(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SubwaySearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subwayLineList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchSubwayByNameCell", for: indexPath) as! SubwayTableViewCell
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
        
            let vc = UIStoryboard(name: "Subway", bundle: nil).instantiateViewController(withIdentifier: "SubwayStationInfoViewController") as! SubwayStationInfoViewController
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
        let stinCd = subwayLineList[sender.tag].stinCd
        let routCd = subwayLineList[sender.tag].routCd
        let stinNm = subwayLineList[sender.tag].stinNm
        callStation(stinCd: stinCd, routCd: routCd, stinNm: stinNm)
    }
}

extension SubwaySearchViewController: UITextFieldDelegate {
    
    // 키보드를 내리며 실행될 행동들
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchStationByName(stinNm: textField.text ?? "")
        return true
    }
    
}
// MARK: API
extension SubwaySearchViewController {
    
    // 해당 역 검색 API (우리 api 활용)
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
    
    // 해당 역 검색 API (우리 api 활용)
    func searchStationByName(stinNm: String) {
        let para : [String: Any] = [
            "stinNm": stinNm
        ]
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_STATION_SEARCH
        AF.request(url, method: .post, parameters: para, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(SearchStationByName.self, from: jsonData)
                    guard let subwayList = getInstanceData.subwayList else { return }
                    var makeData = [SubwayModelBody]()
                    for subway in subwayList {
                        let subwayLine = SubwayModelBody(
                            lnCd: subway.LN_CD ?? "",
                            mreaWideCd: "",
                            railOprIsttCd: subway.RAIL_OPR_ISTT_CD ?? "",
                            routCd: subway.LN_CD ?? "",
                            routNm: subway.LN_NM ?? "",
                            stinCd: subway.STIN_CD ?? "",
                            stinConsOrdr: 0,
                            stinNm: subway.STIN_NM ?? ""
                        )
                        makeData.append(subwayLine)
                    }
                    print("searchStationByName result :: ", makeData)
                    self.subwayLineList = makeData
                    
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}
