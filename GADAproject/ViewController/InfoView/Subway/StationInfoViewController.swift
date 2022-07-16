//
//  TTViewController.swift
//  handycab
//
//  Created by leejungchul on 2021/07/28.
//

import UIKit
import Kingfisher

// 사진 사이즈 조정 필요
class StationInfoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
        
    var imageHeight: CGFloat = 200.0
    
    var stationInfo = [String:[[String]]]()
    
    var imageRawUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("StationInfoViewController viewDidLoad")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSubwayConvenientInfo(_:)), name: .receiveSubwayConvenientInfo, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .receiveSubwayConvenientInfo, object: nil)
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
            imageCell.stationInfoImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "NullImage"))
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
}
