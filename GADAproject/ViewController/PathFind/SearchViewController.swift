import Foundation
import UIKit
import TMapSDK
import MapKit
import ODsaySDK
import SwiftyJSON
import RealmSwift
import Alamofire


class SearchViewController: UIViewController, TMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tmapView: UIView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var taxiCallBtn: UIButton!
    @IBOutlet weak var pathView: UIView!
    @IBOutlet weak var zoomInOutView: UIView!
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var nowLoaction: UIButton!
    
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    
    private var isMapReady:Bool = false
    
    // 아이폰 내장 위치 정보 얻어 오는 함수
    let locationManager = CLLocationManager()
    // 현재 위치 주소로 표현
    public static var currentLocationString: String = ""
    // 현재 위치
    public static var currentLocation = CLLocationCoordinate2D()
    // 시작 위치 표현
    public static var startLocationString: String = ""
    // 출발지 좌표 저장
    static var startLatLon = CLLocationCoordinate2D()
    // 시작 위치 표현
    public static var endLocationString: String = ""
    // 도착지 좌표 저장
    static var endLatLon = CLLocationCoordinate2D()
    // Tmap 표출
    private var mapView: TMapView?
    // POI 검색결과 마커 저장 리스트
    var selectMarker = TMapMarker()
    var marker = TMapMarker()
    
    // 경로탐색 결과 폴리라인 리스트
    var polylines = [TMapPolyline]()
    // POI 검색결과 리스트
    var searchDataList = [SearchList]()
    
    var taxiBtnName = ""
    var taxiphoneNumber = ""
    
    var isFirstLoading = true
        
    let realm = try! Realm()
    
    var favoriteCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        let type = [DataShare.shared().profileDao.hc_type]
        
        print(type)
        if type.contains("2") {
            taxiCallBtn.setTitle("생활이동지원센터 전화하기", for: .normal)
            taxiphoneNumber = "1600-4477"
        } else {
            taxiCallBtn.setTitle("장애인콜택시 전화하기", for: .normal)
            taxiphoneNumber = "1588-4388"
        }
//        favoriteCount = DataShare.shared().favoriteName.count
        favoriteCollectionView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(recieveStartLoactionData(_:)), name: .recieveStartLoactionData, object: nil)
    }
    
    override func viewDidLoad() {
        print("ViewDidLoad")
        super.viewDidLoad()
        favoriteApiSetting()
        
        addVoiceOver()
        
        UsefulUtils.shadowCorner(view: roundView)
        
        UsefulUtils.roundingCorner(view: taxiCallBtn)
        UsefulUtils.shadowCorner(view: taxiCallBtn)
        
        UsefulUtils.roundingCorner(view: nowLoaction)
        UsefulUtils.shadowCorner(view: nowLoaction)
        
        ODsayService.sharedInst().setApiKey(BaseConst.ODSAY_API_KEY)
        ODsayService.sharedInst().setTimeout(10000)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let coord = locationManager.location?.coordinate
        
        print("ViewDidLoad coord : \(coord)")
        if coord != nil {
            SearchViewController.startLatLon = coord!
            isFirstLoading = false
        }
        
        
        mapView = TMapView(frame: tmapView.frame)
        if let m = mapView {
        
            m.delegate = self
            m.setApiKey(BaseConst.MAP_API_KEY)
            m.isZoomEnable = true
            m.backgroundColor = .white
            m.trackingMode = .none
            m.isRotationEnable = true
            tmapView.backgroundColor = .white
            tmapView.addSubview(m)
        }
        debugPrint("is Rotate = \(mapView?.isRotationEnable)")
        
        zoomInOutView.layer.cornerRadius = zoomInOutView.frame.size.width / 2
        UsefulUtils.shadowCorner(view: zoomInOutView)
        collectionViewSetting()
//        favoriteCollectionView.delegate = self
//        favoriteCollectionView.dataSource = self
//        favoriteCollectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: "FavoriteCell")
//        favoriteCollectionView.register(MoreCell.self, forCellWithReuseIdentifier: "MoreCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        NotificationCenter.default.removeObserver(self, name: .recieveStartLoactionData, object: nil)
    }
    
    private func collectionViewSetting() {
        
        let favoriteCollectionViewFlowLayout = UICollectionViewFlowLayout()
        favoriteCollectionViewFlowLayout.scrollDirection = .horizontal
        favoriteCollectionView.showsHorizontalScrollIndicator = false
        favoriteCollectionView.showsVerticalScrollIndicator = false
        favoriteCollectionView.backgroundColor = .clear
        favoriteCollectionView.delegate = self
        favoriteCollectionView.dataSource = self
        
        favoriteCollectionView.register(FavoriteCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "FavoriteCollectionViewCell")
        favoriteCollectionView.register(FavoriteMoreCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "FavoriteMoreCollectionViewCell")
    }
    
    // 출도착지 변경 버튼
    @IBAction func exchangeBtnClick(_ sender: Any) {
        let tempText = startButton.currentTitle
        let tempLatLon = SearchViewController.startLatLon
        let tempLocationString = SearchViewController.startLocationString
        let fontGray = UIColor(named: "color-gray-50") ?? .clear
        
        if endButton.currentTitle == "도착지 입력" {
            startButton.setTitle("출발지 입력", for: .normal)
            startButton.setTitleColor(fontGray, for: .normal)
        } else {
            startButton.setTitle(endButton.currentTitle, for: .normal)
            startButton.setTitleColor(.black, for: .normal)
        }
        SearchViewController.startLocationString = SearchViewController.endLocationString
        SearchViewController.startLatLon = SearchViewController.endLatLon
        
        if tempText == "출발지 입력" {
            endButton.setTitle("도착지 입력", for: .normal)
            endButton.setTitleColor(fontGray, for: .normal)
        } else {
            endButton.setTitle(tempText, for: .normal)
            endButton.setTitleColor(.black, for: .normal)
        }
        SearchViewController.endLocationString = tempLocationString
        SearchViewController.endLatLon = tempLatLon
        print("\(SearchViewController.startLocationString), \(SearchViewController.endLocationString)")
    }
    
    // searchListViewController로 뷰 이동 시키기
    @IBAction func searchEndLocation(_ sender: Any) {
        let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchLocationViewController") as! SearchLocationViewController
        vc.isStart = false
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    // 장애인 콜택시 전화
    @IBAction func callTaxiBtn(_ sender: Any) {
        _ = UsefulUtils.callTo(phoneNumber: taxiphoneNumber)
    }
    
    // 현위치 검색
    @IBAction func nowLoactionBtn(_ sender: Any) {
        let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchLocationViewController") as! SearchLocationViewController
        vc.isStart = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    // 줌 인 버튼
    @IBAction func zoomInBtnClick(_ sender: Any) {
        var zoom: Int = self.mapView?.getZoom() ?? 0
        zoom = zoom + 1
        self.mapView?.animateTo(zoom: zoom)
    }
    
    // 줌 아웃 버튼
    @IBAction func zoomOutBtnClick(_ sender: Any) {
        var zoom: Int = self.mapView?.getZoom() ?? 0
        if zoom == 5 {
            return
        }
        zoom = zoom - 1
        self.mapView?.animateTo(zoom: zoom)
    }
    
    @IBAction func nowLoactionClick(_ sender: Any) {
        print("\(SearchViewController.currentLocation)")
        if SearchViewController.currentLocation.latitude == 0.0 && SearchViewController.currentLocation.longitude == 0.0 {
            return
        }
        getLocation(location: SearchViewController.currentLocation, isReverseGeocoding: true, isChangeStart: true)
    }
    
    @IBAction func unwindToRoot(segue: UIStoryboardSegue) {
        print("move To Root")
        // 외부에서 메인으로 돌아올 경우 상황 초기화
        SearchViewController.startLocationString = SearchViewController.currentLocationString
        SearchViewController.startLatLon = SearchViewController.currentLocation
        SearchViewController.endLatLon = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        startButton.setTitle(SearchViewController.currentLocationString, for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        endButton.setTitle("도착지 입력", for: .normal)
        endButton.setTitleColor(UIColor(named: "color-gray-50"), for: .normal)
    }
    
    func favoriteApiSetting() {
        DataShare.shared().favoriteDataList.removeAll()
        let nickName = DataShare.shared().profileDao.name ?? "테스트"

        // MARK: nickname이 없어서 그에 따른 분기가 필요함.
        let params: [String:Any] = [
            "nickname" : "테스트"
        ]
        print("nickName - \(nickName)")
        let path = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_FAVORITE_READ
        
        AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString).responseJSON { response in

            switch response.result {
            case .success(let result):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode([Favorite].self, from: jsonData)
                    DataShare.shared().favoriteDataList = getInstanceData
                    print("getInstanceData : \(getInstanceData)")
                    self.favoriteCollectionView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getLocation(location: CLLocationCoordinate2D, isReverseGeocoding: Bool, isChangeStart: Bool, isLocationUpdate: Bool = false) {
        // 마커 삭제
        self.marker.map = nil
        self.marker = TMapMarker()
//        removeMarker()
        // 현위치로 이동
        self.mapView?.animateTo(location: location)
        // 현 위치에 마커 생성
        self.marker = TMapMarker(position: location)
        // 지도에 마커 적용
        self.marker.icon = UIImage(named: "icNowLocationMarker")
        self.marker.map = self.mapView
        
        if !isReverseGeocoding {
            return
        }
        
        if isChangeStart {
            SearchViewController.startLatLon = location
        }
        
        let pathData = TMapPathData()
        
        pathData.reverseGeocoding(location, addressType: "A04") { (result, error) -> Void in
            if let result = result {
                let address = result["fullAddress"] as? String
                DispatchQueue.main.async {
                    SearchViewController.currentLocationString = address ?? ""
                    SearchViewController.startLocationString = address ?? ""
                    self.startButton.setTitle(address, for: .normal)
                }
            }
        }
    }
    
    // 마커제거 함수화
//    func removeMarker() {
//        for marker in markers {
//            marker.map = nil
//        }
//        markers.removeAll()
//    }
}

// MARK: 노티피케이션 관련 정보 처리
extension SearchViewController {
    // 노티피케이션을 이용한 검색 값 전달
    @objc func recieveStartLoactionData(_ notification: Notification) {
        print("recieveStartLoactionData - 111111")
    
        // 노티피케이션을 통해 리스트 형태로 정보 받음
        guard let searchData = notification.object as? (startName: String, startLatLon: CLLocationCoordinate2D, endName: String, endLatLon: CLLocationCoordinate2D) else { return }
        selectMarker.map = nil
        selectMarker = TMapMarker()
        if searchData.startLatLon.latitude != 0.0 && searchData.startLatLon.longitude != 0.0 {
            
            self.mapView?.animateTo(location: searchData.startLatLon)
            // 현 위치에 마커 생성
            self.selectMarker = TMapMarker(position: searchData.startLatLon)
            // 지도에 마커 적용
            self.selectMarker.icon = UIImage(named: "icEndPoint")
            self.selectMarker.map = self.mapView
            
        } else if searchData.endLatLon.latitude != 0.0 && searchData.endLatLon.longitude != 0.0 {
            
            self.mapView?.animateTo(location: searchData.endLatLon)
            // 현 위치에 마커 생성
            self.selectMarker = TMapMarker(position: searchData.endLatLon)
            // 지도에 마커 적용
            self.selectMarker.icon = UIImage(named: "icEndPoint")
            self.selectMarker.map = self.mapView
        }
        
        // 각각 변수에 아이템들 부여
        print("searchData - \(searchData)")
        startButton.setTitle(searchData.startName, for: .normal)
        startButton.setTitleColor(searchData.startName == "출발지 입력" ? UIColor(named: "color-gray-50") : .black, for: .normal)
        SearchViewController.startLocationString = searchData.startName
        SearchViewController.startLatLon = searchData.startLatLon
        
        endButton.setTitle(searchData.endName, for: .normal)
        endButton.setTitleColor(searchData.endName == "도착지 입력" ? UIColor(named: "color-gray-50") : .black, for: .normal)
        SearchViewController.endLocationString = searchData.endName
        SearchViewController.endLatLon = searchData.endLatLon
        
    }
    
    // 토스트 출력
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
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
// MARK: 로케이션 관련 익스텐션
extension SearchViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude), \(locValue.longitude)")
        SearchViewController.currentLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        
        if isFirstLoading {
            SearchViewController.startLatLon = SearchViewController.currentLocation
            isFirstLoading = false
        }
        locationUpdate()
    }
    
    func mapViewDidFinishLoadingMap() {
        print("mapViewDidFinishLoadingMap")
        isMapReady = true
        
        let position = SearchViewController.currentLocation
        
        let pathData = TMapPathData()
        self.marker.map = nil
        self.marker = TMapMarker()
        
        pathData.reverseGeocoding(position, addressType: "A04") { (result, error) -> Void in
            if let result = result {
                SearchViewController.currentLocationString = result["fullAddress"] as? String ?? ""
                DispatchQueue.main.async {
                    
                    self.marker = TMapMarker(position: position)
                    self.marker.title = "title"
                    self.marker.draggable = true
                    self.marker.icon = UIImage(named: "icNowLocationMarker")
                    self.marker.map = self.mapView
                    
                    self.mapView?.setCenter(position)
                    self.startButton.setTitle(SearchViewController.currentLocationString, for: .normal)
                    self.startButton.accessibilityLabel = SearchViewController.currentLocationString
                    
                    SearchViewController.startLocationString = SearchViewController.currentLocationString
                }
                print(result["fullAddress"] as? String)
            }
        }
    }
    
//    func mapViewDidChangeBounds() {
//        print("mapViewDidChangeBounds")
//        if let m = mapView {
//            let zoom: Int = self.mapView?.getZoom() ?? 0
//            if zoom < 6 {
//                if SearchViewController.currentLocationString == "" { return }
//                let latitude = SearchViewController.currentLocation.latitude
//                let longitude = SearchViewController.currentLocation.longitude
//                let position: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
//                m.setCenter(position)
//                m.setZoom(6)
//            }
//        }
//    }
    
    func locationUpdate() {
        if !isMapReady { return }
        if SearchViewController.currentLocationString == "" {
            getLocation(location: SearchViewController.currentLocation, isReverseGeocoding: true, isChangeStart: false, isLocationUpdate: false)
        }
    }
}
// MARK: 즐겨찾기 컬렉션뷰 관련 함수
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let count = DataShare.shared().favoriteDataList.count
        
        let sx = SearchViewController.startLatLon.longitude
        let sy = SearchViewController.startLatLon.latitude
//        print(DataShare.shared().favoriteDataList[row])
        
        if row == 0 {
            print("현위치")
        }
        else if row == 1 {
            print("집")
            if DataShare.shared().favoriteDataList[row].lat == 0 && DataShare.shared().favoriteDataList[row].lon == 0 {
                let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "FavoriteAddViewController") as! FavoriteAddViewController
                vc.isHome = true
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                present(vc, animated: true, completion: nil)
            } else {
                let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchPathViewController") as! SearchPathViewController
                
                let endName = DataShare.shared().favoriteDataList[row].name ?? ""
                let endLat = DataShare.shared().favoriteDataList[row].lat
                let endLon = DataShare.shared().favoriteDataList[row].lon
                
                var searchData = (startName: "", startLatLon: CLLocationCoordinate2D(), endName: "", endLatLon: CLLocationCoordinate2D())
                
                searchData.startName = SearchViewController.currentLocationString
                searchData.startLatLon = SearchViewController.currentLocation
                searchData.endName = endName
                searchData.endLatLon = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
                
                let startPoint = CLLocation(latitude: sy, longitude: sx)
                let endPoint = CLLocation(latitude: endLat, longitude: endLon)
               
                let distance = startPoint.distance(from: endPoint)
                if distance < 750 {
                    print("distance : \(distance)")
                    showToast(message: "700m 이하의 거리는 탐색이 불가능 합니다.", font: UIFont(name: "NotoSansCJKkr-light", size: 12.0)!)
                    return
                }
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .coverVertical
                present(vc, animated: true, completion: nil)
                //----------------------
                print("realm저장-------------------1")
                let recentSearchPath = RecentSearchPath()
                recentSearchPath.startAddress = SearchViewController.currentLocationString
                recentSearchPath.startLat = String(sy)
                recentSearchPath.startLon = String(sx)
                recentSearchPath.endAddress = endName
                recentSearchPath.endLat = String(endLat)
                recentSearchPath.endLon = String(endLon)
                try! realm.write {
                    // realm DB에 추가 (C)
                    print("realm저장---------------2")
                    realm.add(recentSearchPath)
                }
                //----------------------
                NotificationCenter.default.post(name: .recieveLoactionData, object: searchData)
            }
        }/*
        else if row == count - 1 {
            print("위치추가 로직 실행")
            let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "FavoriteAddViewController") as! FavoriteAddViewController
            vc.isHome = false
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        }*/
        else if row == count {
            print("등록된 장소 더보기")
            let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "FavoriteMoreViewController") as! FavoriteMoreViewController
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } 
        else {
            print("나머지 \(row)")
            let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchPathViewController") as! SearchPathViewController
            
            let endName = DataShare.shared().favoriteDataList[row].name ?? ""
            let endLat = DataShare.shared().favoriteDataList[row].lat
            let endLon = DataShare.shared().favoriteDataList[row].lon
            
            var searchData = (startName: "", startLatLon: CLLocationCoordinate2D(), endName: "", endLatLon: CLLocationCoordinate2D())
            
            searchData.startName = SearchViewController.currentLocationString
            searchData.startLatLon = SearchViewController.currentLocation
            searchData.endName = endName
            searchData.endLatLon = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
            
            let startPoint = CLLocation(latitude: sy, longitude: sx)
            let endPoint = CLLocation(latitude: endLat, longitude: endLon)
           
            let distance = startPoint.distance(from: endPoint)
            if distance < 750 {
                print("distance : \(distance)")
                showToast(message: "700m 이하의 거리는 탐색이 불가능 합니다.", font: UIFont(name: "NotoSansCJKkr-light", size: 12.0)!)
                return
            }

            
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            
            present(vc, animated: true, completion: nil)
            //----------------------
            print("realm저장-------------------1")
            let recentSearchPath = RecentSearchPath()
            recentSearchPath.startAddress = SearchViewController.currentLocationString
            recentSearchPath.startLat = String(sy)
            recentSearchPath.startLon = String(sx)
            recentSearchPath.endAddress = endName
            recentSearchPath.endLat = String(endLat)
            recentSearchPath.endLon = String(endLon)
            try! realm.write {
                // realm DB에 추가 (C)
                print("realm저장---------------2")
                realm.add(recentSearchPath)
            }
            //----------------------
            NotificationCenter.default.post(name: .recieveLoactionData, object: searchData)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = indexPath.row
        if (row >= DataShare.shared().favoriteDataList.count) {
            return CGSize(width: 30, height: 30)
        } else {
            return FavoriteCollectionViewCell.fittingSize(availableHeight: 30, name: DataShare.shared().favoriteDataList[row].customName)
        }
    }
}

extension SearchViewController {
    func addVoiceOver() {
        // 보이스오버 추가
        startButton.isAccessibilityElement = true
        startButton.accessibilityHint = "클릭하면 출발지를 검색할 수 있습니다."
        
        endButton.isAccessibilityElement = true
        endButton.accessibilityHint = "클릭하면 도착지를 검색할 수 있습니다."
        
        tmapView.isAccessibilityElement = false
        
        zoomInOutView.isAccessibilityElement = false
        
        nowLoaction.isAccessibilityElement = true
        nowLoaction.accessibilityHint = "클릭하면 현위치로 출발지가 설정됩니다."
    }
}
