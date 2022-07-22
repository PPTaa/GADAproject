//
//  SearchListViewController2.swift
//  HANDYCAB_RE
//
//  Created by leejungchul on 2021/05/21.
//

import UIKit
import TMapSDK
import RealmSwift
import Speech
import CoreLocation

class SearchLocationViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var searchViewContainer: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var sttBtn: UIButton!
    @IBOutlet weak var textCancelBtn: UIButton!
    
//    @IBOutlet var favoriteCollectionView: UICollectionView!
    
    private var STTDialog:STTPopupView!

    
    // MARK: STT - 변수처리
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var isStart: Bool = false
    var isSearch: Bool = false

    let realm = try! Realm()
    
    // POI 검색결과 리스트
    var searchDataList = [SearchList]()
    var searchType = ""
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad SearchLocationViewController isStart = \(isStart)")
        print("viewDidLoad SearchLocationViewController isSearch = \(isSearch)")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionFooterHeight = 0
        
//        favoriteCollectionView.delegate = self
//        favoriteCollectionView.dataSource = self
        
        searchTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // MARK: STT - 실행 처리
        speechRecognizer?.delegate = self
        searchViewContainer.layer.borderWidth = 1
        searchViewContainer.layer.borderColor = UIColor.inputDefault?.cgColor
        searchViewContainer.layer.cornerRadius = 2
        
        
//        UsefulUtils.roundingCorner(view: searchTextField, borderColor: UIColor(named: "color-gray-30") ?? .clear)
//        searchTextField.backgroundColor = UIColor(named: "color-gray-10")
//        searchTextField.addLeftPadding()
        if isStart {
            searchTextField.placeholder = "출발지 입력"
        }
        
//        configureCollectionView()
//        registerCollectionView()
//        collectionViewDelegate()
//        collectionViewSetting()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recieveSearchData(_:)), name: .recieveSearchData, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear SearchLocationViewController")
        super.viewWillAppear(true)
//        favoriteCollectionView.reloadData()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .recieveSearchData, object: nil)
    }
    
    @IBAction func textfieldDidChange(_ sender: UITextField) {
        print(sender.text)
        if sender.text == "" {
            searchDataList.removeAll()
            isSearch = false
            tableView.reloadData()
        }
    }
    
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        searchTextField.text = ""
    }
    
    @IBAction func speechToText(_ sender: Any) {
        DispatchQueue.main.async {
            [self] in
            
            if STTDialog != nil { STTDialog.dismiss(animated: false, completion: nil) }
            STTDialog = UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "STTPopupView") as! STTPopupView
            STTDialog.modalTransitionStyle = .crossDissolve
            STTDialog.modalPresentationStyle = .overCurrentContext
            STTDialog.delegate = self
            
            STTDialog.descString = "text_join_9".localized()
            STTDialog.confirmString = "confirm".localized()
            STTDialog.confirmClick = { () -> () in }
            
            present(STTDialog, animated: true, completion: nil)
        }
    }
    
    // 장소 검색 POI
    func search(keyword: String) {
        print("keyword : \(keyword)")
        // 검색 키워드 저장
        
        let recentSearch = RecentSearch()
        recentSearch.name = keyword
        dateFormatter.dateFormat = "yy.MM.dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let saveDate = dateFormatter.string(from: Date())
        let date = saveDate.components(separatedBy: " ")[0]
        recentSearch.date = date
        recentSearch.time = saveDate
 
        // date를 기준으로 Sort!!
        if let userinfo = realm.objects(RecentSearch.self).filter("name == '\(keyword)' AND date == '\(date)'").first {

            try! realm.write {
                realm.delete(userinfo)
            }
            try! realm.write {
                realm.add(recentSearch)
            }
        } else {
            try! realm.write {
                realm.add(recentSearch)
            }
        }
        var model = realm.objects(RecentSearch.self)
        model = model.sorted(byKeyPath: "time", ascending: true)
        print(model)
        
        // 검색
        isSearch = true
        SLoader.showLoading()
        self.searchDataList.removeAll()
        
        let pathData = TMapPathData()
        // POI 데이터 활용한 장소검색
        print("장소검색")
        pathData.requestFindAllPOI(keyword,count: 50) { (result, error) -> Void in
            guard let result = result else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    SLoader.hide()
                }
                return
            }
            for poi in result {
                let data: SearchList = SearchList(
                    name: poi.name!,
                    address: poi.address!,
                    lat: String(poi.coordinate!.latitude),
                    lon: String(poi.coordinate!.longitude),
                    bizName: poi.middleBizName!
                )
                self.searchDataList.append(data)
            }
            CATransaction.begin()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                SLoader.hide()
            }
            CATransaction.commit()
        }
    }
    /*
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
     */
//    func registerCollectionView() {
//        favoriteCollectionView.register(FavoriteCell.self
//                                        , forCellWithReuseIdentifier: "FavoriteCell")
//        favoriteCollectionView.register(MoreCell.self
//                                        , forCellWithReuseIdentifier: "MoreCell")
//    }
}

// MARK: TableView Config
extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        /*
        if isSearch {
            print("numberOfSections isSearch")
            return 1
        } else {
            return 2
        }
         */
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection \(section)")
        switch section {
//        case 0:
//            if !isSearch { // 검색을 하지 않은 경우
//                let models = realm.objects(RecentSearchPath.self)
//                if models.count == 0 {
//                    return 1
//                }
//                return models.count > 2 ? 2 : models.count
//            } else { // 검색을 한 경우 검색결과 노출을 위한 색션 변경
//                return searchDataList.count
//            }
        case 0:
            if isSearch { // 검색을 한 경우 결과값 개수만큼 셀 생성
                return searchDataList.count
            } else { // 검색을 하지 않은 경우 최근 검색 내용 출력
                let models = realm.objects(RecentSearch.self)
                print(models)
                if models.count == 0 {
                    return 1
                } else {
                    return models.count
                }
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearch {
            print("heightForHeaderInSection isSearch")
            return 8
        } else {
            return 43
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "SearchCellHeader") as! SearchCellHeader
        
        print("viewForHeaderInSection \(section)")
        switch section {
        case 0:
            if isSearch {
                let notingHeaderView = tableView.dequeueReusableCell(withIdentifier: "NothingCell") as! NothingCell
                return notingHeaderView
            } else {
                headerView.headerMoreBtn.isHidden = false
                headerView.headerTitleLabel.text = "최근 검색"
            }
//        case 1:
//            headerView.headerMoreBtn.isHidden = true
//            if isSearch {
//                headerView.headerTitleLabel.text = "검색 결과"
//            } else {
//                headerView.headerTitleLabel.text = "최근 검색"
//            }
        default:
            headerView.headerTitleLabel.text = "section header"
        }
        headerView.headerMoreBtn.tag = section
        headerView.headerMoreBtn.addTarget(self, action: #selector(moreBtnClick), for: .touchUpInside)
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // realm객체 읽어와서 객체들의 데이터 확인 및 표출 (R)
        if indexPath.section == 0 {
            if isSearch {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
                cell.name.text = searchDataList[indexPath.row].name
                cell.address.text = searchDataList[indexPath.row].address
                cell.bizName.text = searchDataList[indexPath.row].bizName
                return cell
            }
//            print("indexPath = \(indexPath) -- ")
//            let models = realm.objects(RecentSearchPath.self)
//            if models.count == 0 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "noneCell", for: indexPath) as! NoneCell
//                cell.basicText.text = "최근 검색한 경로가 없습니다."
//                return cell
//            } else {
//                let count = models.count
//                let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchPathCell", for: indexPath) as! RecentSearchPathCell
//                cell.startAddress.text = models[count - indexPath.row - 1].startAddress
//                cell.endAddress.text = models[count - indexPath.row - 1].endAddress
//                return cell
//            }
//        } else {
            var models = realm.objects(RecentSearch.self)
            models = models.sorted(byKeyPath: "time", ascending: true)
            print("indexPath = \(indexPath)")
            if models.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noneCell", for: indexPath) as! NoneCell
                cell.basicText.text = "최근 검색한 기록이 없습니다."
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! RecentSearchCell
                cell.recentSearchName.text = models[models.count - indexPath.row - 1].name
                cell.recentSearchDate.text = models[models.count - indexPath.row - 1].date.components(separatedBy: " ")[0]
                cell.deleteBtn.tag = models.count - indexPath.row - 1
                cell.deleteBtn.addTarget(self, action: #selector(deleteCellBtnClick), for: .touchUpInside)
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        let row = indexPath.row
        var searchData = (startName: "", startLatLon: CLLocationCoordinate2D(), endName: "", endLatLon: CLLocationCoordinate2D())
        
        if indexPath.section == 0 {
            if isSearch {
                print("isSearch")
                if searchDataList.count == 0 {
                    return
                }
                let selectLat = searchDataList[row].lat
                let selectLon = searchDataList[row].lon
                let selectName = searchDataList[row].name
                var selectData = (selectName: "", selectLatLon: CLLocationCoordinate2D())

                selectData.selectName = selectName
                selectData.selectLatLon = CLLocationCoordinate2D(latitude: Double(selectLat) ?? 0.0, longitude: Double(selectLon) ?? 0.0)
                searchCaseWithSelectData(selectData: selectData)
                

            }
//             else {
//                print("else")
//                var models = realm.objects(RecentSearchPath.self)
//                if models.count == 0 {
//                    return
//                }
//
//                let count = models.count
//
//                searchData.startName = models[count - row - 1].startAddress
//                searchData.endName = models[count - row - 1].endAddress
//                searchData.startLatLon = CLLocationCoordinate2D(latitude: Double(models[count - row - 1].startLat)!, longitude: Double(models[count - row - 1].startLon)!)
//                searchData.endLatLon = CLLocationCoordinate2D(latitude: Double(models[count - row - 1].endLat)!, longitude: Double(models[count - row - 1].endLon)!)
//
//                let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchPathViewController") as! SearchPathViewController
//                vc.modalPresentationStyle = .fullScreen
//                present(vc, animated: true, completion: nil)
//
//                NotificationCenter.default.post(name: .recieveLoactionData, object: searchData)
//            }
//        }
            else {
                var models = realm.objects(RecentSearch.self)
                if models.count == 0 {
                    return
                }
                models = models.sorted(byKeyPath: "time", ascending: true)
                print(models[models.count - row - 1])
                
                searchTextField.text = models[models.count - row - 1].name
                // 검색
                search(keyword: models[models.count - row - 1].name)
            }
        }
    }
    
    func addRealm() {
        print("realm저장-------------------1")
        let recentSearchPath = RecentSearchPath()
        recentSearchPath.startAddress = SearchViewController.startLocationString
        recentSearchPath.startLat = String(SearchViewController.startLatLon.latitude)
        recentSearchPath.startLon = String(SearchViewController.startLatLon.longitude)
        recentSearchPath.endAddress = SearchViewController.endLocationString
        recentSearchPath.endLat = String(SearchViewController.endLatLon.latitude)
        recentSearchPath.endLon = String(SearchViewController.endLatLon.longitude)
        try! realm.write {
            // realm DB에 추가 (C)
            print("realm저장---------------2")
            realm.add(recentSearchPath)
        }
    }
    
    @objc func moreBtnClick(sender: CustomButton) {
        print("moreBtnClick Click \(sender.tag)")
        /*
        let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        if sender.tag == 0 {
            vc.isRecentSearch = false
        } else {
            vc.isRecentSearch = true
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        */
    }
    
    @objc func deleteCellBtnClick(sender: CustomButton) {
        print("sender.tag : \(sender.tag)")
        var models = realm.objects(RecentSearch.self)
        models = models.sorted(byKeyPath: "time", ascending: true)
        do {
            try realm.write {
                realm.delete(models[sender.tag])
            }
        } catch {
            print("error : \(error)")
        }
        tableView.reloadData()
    }
        
}

// MARK: TextField Delegate
extension SearchLocationViewController: UITextFieldDelegate {
    // 키보드 내리기(viewdidload에서 delegate설정을 해줘야 먹힘)
    // 키보드를 내리며 실행될 행동들
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        search(keyword: textField.text!)
        searchType = "end"
        tableView.reloadData()
        return true
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        print("keyboardUP")
        textCancelBtn.isHidden = false
        sttBtn.isHidden = true
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        print("keyboardDOWN")
        textCancelBtn.isHidden = true
        sttBtn.isHidden = false
    }
    
}

// MARK: CollectionView Config
/*
extension SearchLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
//        let count = DataShare.shared().favoriteName.count - 1
        
        let sx = SearchViewController.startLatLon.longitude
        let sy = SearchViewController.startLatLon.latitude
        /*
        if row == 0 {
            print("현위치")
            print(SearchViewController.currentLocation)
            
            let selectName: String = "현위치 : \(SearchViewController.currentLocationString)"
            let selectLatLon = SearchViewController.currentLocation
            let selectLat: String = String(SearchViewController.currentLocation.latitude)
            let selectLon: String = String(SearchViewController.currentLocation.longitude)
            
            var selectData = (selectName: "", selectLatLon: CLLocationCoordinate2D())
            selectData.selectName = selectName
            selectData.selectLatLon = selectLatLon
            
            searchCaseWithSelectData(selectData: selectData)
             
            let startPoint = CLLocation(latitude: Double(sy) ?? 0.0, longitude: Double(sx) ?? 0.0)
            let endPoint = CLLocation(latitude: Double(selectLat) ?? 0.0, longitude: Double(selectLon) ?? 0.0)
            
            let distance = startPoint.distance(from: endPoint)
            if distance < 750 {
                print("distance : \(distance)")
                showToast(message: "700m 이하의 거리는 탐색이 불가능 합니다.", font: UIFont(name: "NotoSansCJKkr-light", size: 12.0)!)
                return
            }
        } else if row == 1 {
            print("집")
            if DataShare.shared().favoriteDao[row].lat == 0 && DataShare.shared().favoriteDao[row].lon == 0 {
                let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteAddViewController") as! FavoriteAddViewController
                vc.isHome = true
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                present(vc, animated: true, completion: nil)
            } else {
                let selectLat = DataShare.shared().favoriteDao[row].lat
                let selectLon = DataShare.shared().favoriteDao[row].lon
                let selectName: String = "\(DataShare.shared().favoriteDao[row].customName) : \(DataShare.shared().favoriteDao[row].name)"
                
                var selectData = (selectName: "", selectLatLon: CLLocationCoordinate2D())
                selectData.selectName = selectName
                selectData.selectLatLon = CLLocationCoordinate2D(latitude: selectLat, longitude: selectLon)
                
                searchCaseWithSelectData(selectData: selectData)
                
                let startPoint = CLLocation(latitude: sy, longitude: sx)
                let endPoint = CLLocation(latitude: selectLat, longitude: selectLon)
               
                let distance = startPoint.distance(from: endPoint)
                if distance < 750 {
                    print("distance : \(distance)")
                    showToast(message: "700m 이하의 거리는 탐색이 불가능 합니다.", font: UIFont(name: "NotoSansCJKkr-light", size: 12.0)!)
                    return
                }
            }
        } else if row == count - 1 {
            print("위치추가 로직 실행")
            let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteAddViewController") as! FavoriteAddViewController
            vc.isHome = false
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else if row == count {
            print("등록된 장소 더보기")
            let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteMoreViewController") as! FavoriteMoreViewController
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else {
            print("나머지 \(row)")
            
            let selectLat = DataShare.shared().favoriteDao[row].lat
            let selectLon = DataShare.shared().favoriteDao[row].lon
            let selectName: String = "\(DataShare.shared().favoriteDao[row].customName) : \(DataShare.shared().favoriteDao[row].name)"
            
            var selectData = (selectName: "", selectLatLon: CLLocationCoordinate2D())
            selectData.selectName = selectName
            selectData.selectLatLon = CLLocationCoordinate2D(latitude: selectLat, longitude: selectLon)
            
            searchCaseWithSelectData(selectData: selectData)

            let startPoint = CLLocation(latitude: sy, longitude: sx)
            let endPoint = CLLocation(latitude: selectLat, longitude: selectLon)

            let distance = startPoint.distance(from: endPoint)
            if distance < 750 {
                print("distance : \(distance)")
                showToast(message: "700m 이하의 거리는 탐색이 불가능 합니다.", font: UIFont(name: "NotoSansCJKkr-light", size: 12.0)!)
                return
            }
        }
         */
    }
}
*/
extension SearchLocationViewController {
    @objc func recieveSearchData(_ notification: Notification) {
        print("noti == recieveSearchData")
        let name = notification.object as! String
        
        let models = realm.objects(RecentSearch.self)
        searchTextField.text = name
        // 검색
        search(keyword: name)
    }
    
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
    
    func searchCaseWithSelectData(selectData: (selectName: String, selectLatLon: CLLocationCoordinate2D)) {
        var searchData = (startName: "", startLatLon: CLLocationCoordinate2D(), endName: "", endLatLon: CLLocationCoordinate2D())
        if isStart {
            //---------------------- 출발지 입력 , 도착지 미존재
            if SearchViewController.endLatLon.latitude == 0.0 || SearchViewController.endLatLon.longitude == 0.0 {
                searchData.startName = selectData.selectName
                searchData.startLatLon = selectData.selectLatLon
                searchData.endName = "도착지 입력"
                searchData.endLatLon = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                //----------------------
                dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .recieveStartLoactionData, object: searchData)
            } else { //---------------------- 출발지 입력 , 도착지 존재
                searchData.startName = selectData.selectName
                searchData.startLatLon = selectData.selectLatLon
                searchData.endName = SearchViewController.endLocationString
                searchData.endLatLon = SearchViewController.endLatLon
                
                SearchViewController.startLocationString = selectData.selectName
                SearchViewController.startLatLon = selectData.selectLatLon
                
                let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchPathViewController") as! SearchPathViewController
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
                //---------------------- add Realm
                addRealm()
                //----------------------
                NotificationCenter.default.post(name: .recieveLoactionData, object: searchData)
                 
            }
        } else {
            //---------------------- 도착지 입력 , 출발지 미존재
            if SearchViewController.startLatLon.latitude == 0.0 || SearchViewController.startLatLon.longitude == 0.0 {
                searchData.startName = "출발지 입력"
                searchData.startLatLon = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                searchData.endName = selectData.selectName
                searchData.endLatLon = selectData.selectLatLon
                //----------------------
                dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .recieveStartLoactionData, object: searchData)
            } else { //---------------------- 도착지 입력 , 출발지 존재
                searchData.startName = SearchViewController.startLocationString
                searchData.startLatLon = SearchViewController.startLatLon
                searchData.endName = selectData.selectName
                searchData.endLatLon = selectData.selectLatLon
                
                SearchViewController.endLocationString = selectData.selectName
                SearchViewController.endLatLon = selectData.selectLatLon
                
                let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "SearchPathViewController") as! SearchPathViewController
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
                //---------------------- add Realm
                addRealm()
                //----------------------
                NotificationCenter.default.post(name: .recieveLoactionData, object: searchData)
                 
            }
        }
    }
}


extension SearchLocationViewController: SttDelegateProtocol {
    func deliverySttText(_ text: String) {
        print("deliverySttText \(text)")
        let name = text
        searchTextField.text = name
        // 검색
        search(keyword: name)
    }
}
