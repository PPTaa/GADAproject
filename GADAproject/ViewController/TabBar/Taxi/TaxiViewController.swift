//
//  TaxiViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit
import Alamofire

class TaxiViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var taxiLocationList: [String] = ["서울", "경기도", "광역시", "세종"]
    var taxiCompanyList: [TaxiListCall] = [TaxiListCall()] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(TaxiCollectionViewCell.self, forCellWithReuseIdentifier: "TaxiCollectionViewCell")
        self.collectionView.reloadData()
        let firstIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .right)
        collectionView(self.collectionView, didSelectItemAt: firstIndexPath)
    }
    @IBAction func tapSearchBtn(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Taxi", bundle: nil).instantiateViewController(withIdentifier: "TaxiSearchViewController") as! TaxiSearchViewController
                
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TaxiViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taxiLocationList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = indexPath.row
        return TaxiCollectionViewCell.fittingSize(availableHeight: 32, name: taxiLocationList[row])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaxiCollectionViewCell", for: indexPath) as! TaxiCollectionViewCell
        cell.setTitle(title: taxiLocationList[row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let lnCd = taxiLocationList[row]
        print("lnCd = \(lnCd)")
        taxiListSetting(idx: row)
    }
    
}

extension TaxiViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
        return taxiCompanyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiListTableCell", for: indexPath) as! TaxiListTableCell
        let row = indexPath.row
        cell.awakeFromNib()
        if taxiCompanyList[row].name == "" {
            cell.detailLabel1.frame.size.width = 0
            cell.detailLabel1.isHidden = true
            cell.detailLine.frame.size.width = 0
            cell.detailLine.isHidden = true
            cell.detailLineLeftConst.constant = 0
            cell.detailLineRightConst.constant = 0
        } else {
            cell.detailLabel1.isHidden = false
            cell.detailLine.frame.size.width = 1
            cell.detailLine.isHidden = false
            cell.detailLineLeftConst.constant = 8
            cell.detailLineRightConst.constant = 8
        }
        cell.detailLabel1.text = taxiCompanyList[row].name
        cell.titleLabel.text = taxiCompanyList[row].call_name
        cell.detailLabel2.text = taxiCompanyList[row].operating_name
        
        cell.callBtn.tag = row
        cell.likeBtn.tag = row
        
        cell.likeBtn.addTarget(self, action: #selector(tapFavoriteBtn), for: .touchUpInside)
        cell.callBtn.addTarget(self, action: #selector(tapPhoneCallBtn), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = UIStoryboard(name: "Taxi", bundle: nil).instantiateViewController(withIdentifier: "TaxiInfoViewController") as! TaxiInfoViewController
        let row = indexPath.row
        vc.basicData = self.taxiCompanyList[row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @objc func tapFavoriteBtn(_ sender: UIButton) {
        // MARK: 즐겨찾기 추가 기능 구현 예정
        sender.isSelected = !sender.isSelected
    }
    
    
    @objc func tapPhoneCallBtn(_ sender: UIButton) {
        let selectData = self.taxiCompanyList[sender.tag]
        let phone_number = selectData.phone_number
        UsefulUtils.callTo(phoneNumber: phone_number)
    }
     
    
}

// MARK: API 모음
extension TaxiViewController {
    private func taxiListSetting(idx: Int) {
        
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_TAXI_LIST
        let params = [
            "division" : taxiLocationList[idx]
        ]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
//                    print(data)
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode([TaxiListCall].self, from: jsonData)
                    print("TaxiListCall result = \(getInstanceData)")
                    self.taxiCompanyList = getInstanceData
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
