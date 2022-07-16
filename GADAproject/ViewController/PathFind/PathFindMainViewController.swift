//
//  PathFindMainViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import UIKit
import SnapKit
import NMapsMap
import CoreLocation
import Alamofire


class PathFindMainViewController: UIViewController {

    @IBOutlet weak var mapView: NMFMapView!
    
    private let coverView = UIView()
    private let startButton = UIButton()
    private let endButton = UIButton()
    private let startIcon = UIImageView()
    private let endIcon = UIImageView()
    private let centerLine = UIView()
    private let centerIcon = UIImageView()
    private let changeButton = UIButton()
        
    private var favoriteCollectionView: UICollectionView!
    
    private let callTaxiButton = UIButton()
    
    private let zoomInOutView = UIView()
    private let zoomInButton = UIButton()
    private let zoomOutButton = UIButton()
    
    // 아이폰 내장 위치 정보 얻어 오는 함수
    let locationManager = CLLocationManager()
    // 현재 위치
    public static var currentLocationString: String = ""
    public static var currentLatLon = CLLocationCoordinate2D()
    // 시작 위치
    public static var startLocationString: String = ""
    public static var startLatLon = CLLocationCoordinate2D()
    // 도착 위치 표현
    public static var endLocationString: String = ""
    public static var endLatLon = CLLocationCoordinate2D()
    
    private var isFirstLoading = true
    
    private var marker = NMFMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestAlwaysAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        callFavorite()
        
        collectionViewSetting()
        layout()
        attribute()
        // Do any additional setup after loading the view.
    }
    
    func callFavorite() {
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_FAVORITE_READ
        let params = [
            "nickname": "테스트"
        ]
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.queryString).responseJSON { response in

            switch response.result {
            case .success(let result):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode([Favorite].self, from: jsonData)
                    DataShare.shared().favoriteDataList = getInstanceData
                    self.favoriteCollectionView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func layout() {
        [coverView, favoriteCollectionView, zoomInOutView, callTaxiButton].forEach {
            view.addSubview($0)
        }
        
        [startIcon, centerIcon, endIcon, startButton, centerLine, endButton, changeButton].forEach {
            coverView.addSubview($0)
        }
        
        [zoomInButton, zoomOutButton].forEach {
            zoomInOutView.addSubview($0)
        }
        
        
        //MARK: ------------------------- Cover View
        coverView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-40)
            
        }
        
        startButton.snp.makeConstraints {
            $0.leading.equalTo(startIcon.snp.trailing).offset(16)
            $0.top.equalTo(coverView).offset(56)
            $0.height.equalTo(23)
        }
        centerLine.snp.makeConstraints {
            $0.leading.trailing.equalTo(startButton)
            $0.top.equalTo(startButton.snp.bottom).offset(6.5)
            $0.height.equalTo(1)
        }
        endButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(centerLine)
            $0.top.equalTo(centerLine).offset(6.5)
            $0.bottom.equalTo(coverView).offset(-22)
            $0.height.equalTo(23)
        }
        
        startIcon.snp.makeConstraints {
            $0.leading.equalTo(coverView).offset(24)
            $0.centerY.equalTo(startButton)
            $0.height.width.equalTo(20)
        }
        centerIcon.snp.makeConstraints {
            $0.centerX.equalTo(startIcon)
            $0.centerY.equalTo(centerLine)
            $0.height.width.equalTo(20)
        }
        endIcon.snp.makeConstraints {
            $0.centerX.equalTo(centerIcon)
            $0.centerY.equalTo(endButton)
            $0.height.width.equalTo(20)
        }
        
        changeButton.snp.makeConstraints {
            $0.leading.equalTo(startButton.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().offset(-40)
            $0.centerY.equalTo(centerLine)
            $0.height.width.equalTo(24)
        }
        
        //MARK: ------------------------- 즐겨찾기 collectionView
        favoriteCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(coverView.snp.bottom).offset(0)
            $0.height.equalTo(50)
        }
        
        //MARK: ------------------------- 하단 뷰
        
        zoomInOutView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalTo(callTaxiButton.snp.top).offset(-40)
            $0.height.equalTo(90)
            $0.width.equalTo(40)
        }
        
        zoomInButton.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(zoomInButton.snp.width).multipliedBy(1)
        }
        
        zoomOutButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(zoomInButton.snp.bottom)
            $0.height.equalTo(zoomOutButton.snp.width).multipliedBy(1)
        }
        
        callTaxiButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
            $0.height.equalTo(45)
        }
        
        
    }

    
    private func attribute() {
        
        mapView.isNightModeEnabled = true
        
        coverView.backgroundColor = .baseBackground
        coverView.roundCorner(radius: 20, arrayLiteral: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        UsefulUtils.shadowCorner(view: coverView, radius: 5)
        
        startIcon.image = UIImage(named: "pathfind_startIcon")
        centerIcon.image = UIImage(named: "pathfind_centerIcon")
        endIcon.image = UIImage(named: "pathfind_endIcon")
        
        startButton.setTitle("출발지 입력", for: .normal)
        startButton.titleLabel?.font = UIFont.notoSans(type: .medium, size: 16)
        startButton.contentHorizontalAlignment = .leading
        startButton.setTitleColor(UIColor(named: "color-gray-50"), for: .normal)
        
        endButton.setTitle("도착지 입력", for: .normal)
        endButton.titleLabel?.font = UIFont.notoSans(type: .medium, size: 16)
        endButton.contentHorizontalAlignment = .leading
        endButton.setTitleColor(UIColor(named: "color-gray-50"), for: .normal)
        
        centerLine.backgroundColor = UIColor(named: "color-gray-30")
        
        changeButton.setImage(UIImage(named: "pathfind_changeIcon"), for: .normal)
        
        zoomInOutView.backgroundColor = .baseBackground
        zoomInOutView.roundCorner(radius: 20)
        UsefulUtils.shadowCorner(view: zoomInOutView, radius: 10)
        
        zoomInButton.setImage(UIImage(named: "pathfind_zoomIn"), for: .normal)
        zoomOutButton.setImage(UIImage(named: "pathfind_zoomOut"), for: .normal)
        
        callTaxiButton.backgroundColor = .black
        callTaxiButton.titleLabel?.font = UIFont.notoSans(type: .bold, size: 18)
        callTaxiButton.setTitle("장애인콜택시 전화하기", for: .normal)
        callTaxiButton.setTitleColor(UIColor(named: "color-white"), for: .normal)
        callTaxiButton.roundCorner(radius: 22.5)
        
    }
    
    private func collectionViewSetting() {
        
        let favoriteCollectionViewFlowLayout = UICollectionViewFlowLayout()
        favoriteCollectionViewFlowLayout.scrollDirection = .horizontal
        
        
        favoriteCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: favoriteCollectionViewFlowLayout)
        favoriteCollectionView.showsHorizontalScrollIndicator = false
        favoriteCollectionView.showsVerticalScrollIndicator = false
        favoriteCollectionView.backgroundColor = .clear
        favoriteCollectionView.delegate = self
        favoriteCollectionView.dataSource = self
        
        favoriteCollectionView.register(FavoriteCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "FavoriteCollectionViewCell")
        favoriteCollectionView.register(FavoriteMoreCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "FavoriteMoreCollectionViewCell")
    }
    
    
}

extension PathFindMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = indexPath.row
        if (row >= DataShare.shared().favoriteDataList.count) {
            return CGSize(width: 30, height: 30)
        } else {
            return FavoriteCollectionViewCell.fittingSize(availableHeight: 30, name: DataShare.shared().favoriteDataList[row].customName)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataShare.shared().favoriteDataList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCollectionViewCell", for: indexPath) as! FavoriteCollectionViewCell
        if ( row >= DataShare.shared().favoriteDataList.count) {
            let moreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteMoreCollectionViewCell", for: indexPath) as! FavoriteMoreCollectionViewCell
            return moreCell
        }
        let customName = DataShare.shared().favoriteDataList[row].customName
        
        cell.titleLabel.text = customName
        switch customName {
        case "현위치":
            cell.configure(name: customName, imageName: "favoriteCell_currentLocation")
        case "집":
            cell.configure(name: customName, imageName: "favoriteCell_home")
        case "추가하기":
            cell.configure(name: customName, imageName: "favoriteCell_more")
        default:
            cell.configure(name: customName, imageName: "favoriteCell_default")
        }
        
        
        UsefulUtils.shadowCorner(view: cell, radius: 5)
        
        return cell
    }
}

extension PathFindMainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location =  manager.location?.coordinate else { return }
        print("lat : \(location.latitude), lon : \(location.longitude)")
        print("locations : \(locations)")
        PathFindMainViewController.currentLatLon = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        if isFirstLoading {
            PathFindMainViewController.startLatLon = PathFindMainViewController.currentLatLon
            isFirstLoading = false
        }
        locationUpdate()
    }
    
    func locationUpdate() {
        if PathFindMainViewController.currentLocationString == "" {
            getLocation(location: PathFindMainViewController.currentLatLon, isReverseGeocoding: true, isChangeStart: false, isLocationUpdate: false)
        }
    }
    
    func getLocation(location: CLLocationCoordinate2D, isReverseGeocoding: Bool, isChangeStart: Bool, isLocationUpdate: Bool = false) {
        print("getlocation : \(location)")
        // 마커 삭제
        self.marker.mapView = nil
        self.marker = NMFMarker()
        
        // 현위치로 이동
        let nowNMGLatLng = NMGLatLng(lat: location.latitude, lng: location.longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: nowNMGLatLng)
        self.mapView.moveCamera(cameraUpdate)
        // 현 위치에 마커 생성
        self.marker.position = nowNMGLatLng
        // 마커 이미지 변경
        let image = NMFOverlayImage(name: "map_nowLocationMarker")
        self.marker.iconImage = image
        // 지도에 마커 적용
        self.marker.mapView = self.mapView


        
//        if !isReverseGeocoding {
//            return
//        }
//
//        if isChangeStart {
//            SearchViewController_re.startLatLon = location
//        }
//
        reverseGeocoding(coord: location)
    }
    
    
    func reverseGeocoding(coord: CLLocationCoordinate2D) {
        // 리버스지오코딩 관련 더찾아봐야함.
        let url = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
        let headers: HTTPHeaders = [
                "X-NCP-APIGW-API-KEY-ID": "hwygapp21r",
                "X-NCP-APIGW-API-KEY": "Nr3Qz6825b8Fr1wsJmIfwPPMCCl98vgKRaxMbs4i"
            ]
        let params = [
            "coords": "\(coord.longitude),\(coord.latitude)",
            "orders": "addr",
            "output": "json"
        ]
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: headers).responseJSON { response in

            switch response.result {
            case .success(let result):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(ReverseGCModel.self, from: jsonData)
                    print("good", getInstanceData)
                    var locationString = ""
                    for result in getInstanceData.results {
                        var area4Name = ""
                        if result.region.area4.name != "" {
                            area4Name = "\(result.region.area4.name) "
                        }
                        locationString = result.region.area1.name + " " + result.region.area2.name + " " + result.region.area3.name + " " + area4Name + result.land.number1 + "-" + result.land.number2
                    }
                    DispatchQueue.main.async {
                        PathFindMainViewController.currentLocationString = locationString
                        PathFindMainViewController.startLocationString = locationString
                        self.startButton.setTitle(locationString, for: .normal)
                    }
                    print(PathFindMainViewController.currentLocationString)
                } catch {
                    print("catch", error.localizedDescription)
                }
            case .failure(let error):
                print("failure", error.localizedDescription)
            }
        }
    }
}
