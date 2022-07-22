//
//  TaxiViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit
import Alamofire
import CoreLocation
import TMapSDK
import SwiftyJSON


class TaxiViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var locationStringLabel: UILabel!
    
    @IBOutlet weak var taxiName: UILabel!
    @IBOutlet weak var taxiDetailName1: UILabel!
    @IBOutlet weak var taxiDetailName2: UILabel!
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var locationManager: CLLocationManager!
    
    var taxiLocationList: [String] = ["서울", "경기도", "광역시", "세종"]
    var taxiAllCompanyList: [TaxiListCall]?
    var taxiCompanyList: [TaxiListCall] = [TaxiListCall()] {
        didSet {
            tableView.reloadData()
        }
    }
    var nowLocationTaxi: TaxiListCall = TaxiListCall() {
        didSet {
            DispatchQueue.main.async {
                self.taxiName.text = self.nowLocationTaxi.call_name
                self.taxiDetailName1.text = self.nowLocationTaxi.name
                self.taxiDetailName2.text = self.nowLocationTaxi.operating_name
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardView.layer.cornerRadius = 10
        
        taxiAllListSetting()
        locationConfig()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(TaxiCollectionViewCell.self, forCellWithReuseIdentifier: "TaxiCollectionViewCell")
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        let firstIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .right)
        collectionView(self.collectionView, didSelectItemAt: firstIndexPath)
    }
    
    @IBAction func tapSearchBtn(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Taxi", bundle: nil).instantiateViewController(withIdentifier: "TaxiSearchViewController") as! TaxiSearchViewController
                
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func tapCallBtn(_ sender: Any) {
        let selectData = self.nowLocationTaxi
        let phone_number = selectData.phone_number
        UsefulUtils.callTo(phoneNumber: phone_number)
    }
    
    @IBAction func tapLikeBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    func locationConfig() {
        
        // 위치정보 받아오기
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        var location = CLLocationCoordinate2D()
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 온")
            locationManager.startUpdatingLocation()
            print(locationManager.location?.coordinate)
            location = locationManager.location?.coordinate ?? CLLocationCoordinate2D()
            // 37.8581399,126.7836315
//            location = CLLocationCoordinate2D(latitude: 37.8581399, longitude: 126.7836315)
            reverseGeocode(location: location)
        } else {
            print("위치 서비스 오프")
        }
    }
    
    func reverseGeocode(location:CLLocationCoordinate2D) {
        
        let url = "https://apis.openapi.sk.com/tmap/geo/reversegeocoding?version=1&format=json&callback=result"
        
        let params: [String : Any] = [
            "appKey" : BaseConst.MAP_API_KEY,
            "coordType" : "WGS84GEO",
            "addressType" : "A10",
            "lon" : location.longitude,
            "lat" : location.latitude
        ]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).responseJSON { response in

            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                print("jsonData: \(jsonData["addressInfo"])")
                let siDo = jsonData["addressInfo"]["city_do"].stringValue
                let guGun = jsonData["addressInfo"]["gu_gun"].stringValue
                
                DispatchQueue.main.async {
                    self.locationStringLabel.text = "\(siDo) \(guGun)"
                }
                
                
                if siDo.contains("서울") {
                    for i in self.taxiAllCompanyList! {
                        if i.region == "서울" {
                            self.nowLocationTaxi = i
                            break
                        }
                    }
                } else {
                    for i in self.taxiAllCompanyList! {
                        print(":--------------")
                        print(i, guGun)
                        print(i.region.contains(guGun))
                        print(guGun.contains(i.region))
                        if i.region.contains(guGun) || guGun.contains(i.region) {
                            self.nowLocationTaxi = i
                            break
                        }
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
        
        let path = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_TAXI_LIST + taxiLocationList[idx]

        AF.request(path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", method: .get).responseJSON { response in
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
    
    private func taxiAllListSetting() {
        
        let path = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_TAXI_LIST

        AF.request(path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", method: .get).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode([TaxiListCall].self, from: jsonData)
                    print("TaxiListCall result = \(getInstanceData)")
                    self.taxiAllCompanyList = getInstanceData
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
