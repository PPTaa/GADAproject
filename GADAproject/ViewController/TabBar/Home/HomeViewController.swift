//
//  HomeViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SnapKit

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var juSoLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var maxMinTemperatureLabel: UILabel!
    
    @IBOutlet weak var fineDustState: UILabel!
    @IBOutlet weak var ultraFineDustState: UILabel!
    
    @IBOutlet weak var pathFindView: UIView!
    
    @IBOutlet weak var togetherChallengeStackView: UIStackView!
    @IBOutlet weak var togetherStoreStackView: UIStackView!
    
    
    var challengeList = [ChallengeData]()
    var storeList = [StoreData]()
    
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pathFindView.roundCorner(radius: 10)
        challengeAndStoreSetting()
        locationConfig()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapGotoPathFind(_ sender: Any) {
        let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func tapThemeSwitch(_ sender: UISwitch) {
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if sender.isOn {
                appDelegate?.overrideUserInterfaceStyle = .dark
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
            }
        } else {
            // Fallback on earlier versions
            
        }
    }
    func challengeAndStoreSetting() {
        let firstChallenge = ChallengeData(title: "???????????? ???????????? ????????????!", subTitle: "22.07.31 ????????????", imageRoute: "challengeImage-1")
        
        let firstStore = StoreData(likeCount: 749, storeTitle: "???????????????", storeCategory: "??????/????????????", storeDescription: "???????????? ???????????? ???????????? ???????????? ????????? ???????????? ?????? ????????? ??????????????? ????????? ????????? ????????? ??????", storeTag: "????????? ?????? ?? ???????????? ?? ???????????? ?? ???????????? ?? ????????? ????????? ??????", storeImageRoute: "storeImage-1")
        
        let secondStore = StoreData(likeCount: 316, storeTitle: "????????????", storeCategory: "??????/????????????", storeDescription: "?????? ????????? ???????????? ?????? ????????? ????????? ?????? ??????", storeTag: "???????????? ????????? ????????? ?? ????????? ?????? ??????", storeImageRoute: "storeImage-2")
        
        let thirdStore = StoreData(likeCount: 126, storeTitle: "?????? ??????NC?????????", storeCategory: "?????????", storeDescription: "?????? ????????? ???????????? ????????? ?????? ??? ?????? ?????? ?????????", storeTag: "???????????? ????????? ????????? ?? ??????????????? ?? ????????? ????????? ?? ????????? ????????? ?? ???????????????", storeImageRoute: "storeImage-3")
        
        storeList = [firstStore, secondStore, thirdStore]
        challengeList = [firstChallenge]
        configureStackView()
        
    }
    
    func locationConfig() {
        // ???????????? ????????????
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        var location = CLLocationCoordinate2D()
        if CLLocationManager.locationServicesEnabled() {
            print("?????? ????????? ???")
            locationManager.startUpdatingLocation()
            print(locationManager.location?.coordinate)
            location = locationManager.location?.coordinate ?? CLLocationCoordinate2D()
            // 37.8581399,126.7836315
            
            reverseGeocode(location: location)
            weatherAPICall(location: location)
//            transcoordWithKakao(lat: location.latitude, lon: location.longitude)
        } else {
            print("?????? ????????? ??????")
        }
    }
    
    private func configureStackView() {
        for (idx,challenge) in challengeList.enumerated() {
            let challengeView = makeChallengeView(idx: idx, challenge: challenge)
            togetherChallengeStackView.addArrangedSubview(challengeView)
        }
        for (idx, store) in storeList.enumerated() {
            let storeView = makeStoreView(idx: idx, store: store)
            togetherStoreStackView.addArrangedSubview(storeView)
        }
    }
}
extension HomeViewController {
    private func makeChallengeView(idx: Int, challenge: ChallengeData) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "\(challenge.imageRoute ?? "")")
        
        let titleLabel = UILabel()
        titleLabel.textColor = .textPrimary
        titleLabel.font = .pretendard(type: .bold, size: 18)
        titleLabel.text = challenge.title
        
        let subTitleLabel = UILabel()
        subTitleLabel.textColor = .textSecondary
        subTitleLabel.font = .pretendard(type: .medium, size: 14)
        subTitleLabel.text = challenge.subTitle
        
        let challengeButton = UIButton()
        challengeButton.setTitle("", for: .normal)
        challengeButton.tag = idx
        challengeButton.backgroundColor = .clear
        challengeButton.addTarget(self, action: #selector(tapChallengeButton), for: .touchUpInside)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view).offset(71)
            $0.height.equalTo(28)
            $0.leading.equalTo(view).offset(17)
        }
        
        view.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.bottom.equalTo(view).offset(-14)
            $0.height.equalTo(24)
            $0.leading.equalTo(titleLabel)
        }
        
        view.addSubview(challengeButton)
        challengeButton.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        return view
    }
    
    private func makeStoreView(idx: Int, store: StoreData) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let imageLayoutView = UIView()
        imageLayoutView.backgroundColor = .systemPink
        imageLayoutView.layer.cornerRadius = 10
        imageLayoutView.layer.borderColor = UIColor.clear.cgColor
        imageLayoutView.layer.borderWidth = 1
        imageLayoutView.layer.masksToBounds = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "\(store.storeImageRoute ?? "")")
        
        let likeView = UIView()
        likeView.backgroundColor = .clear
//        likeView.backgroundColor = .baseBackground?.withAlphaComponent(0.5)
//        likeView.layer.cornerRadius = 10
//        likeView.layer.maskedCorners = CACornerMask(arrayLiteral: [.layerMaxXMaxYCorner, .layerMinXMinYCorner])
//        likeView.layer.borderColor = UIColor.clear.cgColor
//        likeView.layer.borderWidth = 1
//        likeView.layer.masksToBounds = true
        
        let likeButton = UIButton()
        likeButton.backgroundColor = .clear
        likeButton.tag = idx
        likeButton.setImage(UIImage(named: "like_24"), for: .normal)
        likeButton.setImage(UIImage(named: "like_filled_24"), for: .selected)
        likeButton.setTitle("\(store.likeCount)", for: .normal)
        likeButton.setTitleColor(.textBtnActive, for: .normal)
        likeButton.addTarget(self, action: #selector(tapLikeButton), for: .touchUpInside)

        
        let titleLabel = UILabel()
        titleLabel.textColor = .textPrimary
        titleLabel.font = .pretendard(type: .bold, size: 18)
        titleLabel.text = store.storeTitle
        
        let titleIcon = UIImageView()
        titleIcon.image = UIImage(named: "chevron_right_24")
        
        let titleButton = UIButton()
        titleButton.setTitle("", for: .normal)
        titleButton.tag = idx
        titleButton.backgroundColor = .clear
        titleButton.addTarget(self, action: #selector(tapTitleButton), for: .touchUpInside)
        
        let categoryView = UIView()
        categoryView.backgroundColor = .primaryGreen100
        categoryView.layer.cornerRadius = 14
        categoryView.layer.borderColor = UIColor.clear.cgColor
        categoryView.layer.borderWidth = 1
        categoryView.layer.masksToBounds = true

        let categoryLabel = UILabel()
        categoryLabel.textColor = .primaryGreen600
        categoryLabel.font = .pretendard(type: .medium, size: 14)
        categoryLabel.text = store.storeCategory
        
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .textPrimary
        descriptionLabel.font = .pretendard(type: .medium, size: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = store.storeDescription
        
        let tagLabel = UILabel()
        tagLabel.textColor = .textSecondary
        tagLabel.font = .pretendard(type: .regular, size: 14)
        tagLabel.numberOfLines = 0
        tagLabel.text = store.storeTag
        
        let lineView = UIView()
        lineView.backgroundColor = .baseBorder
        
        view.addSubview(imageLayoutView)
        imageLayoutView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
            $0.height.equalTo(183)
        }
        imageLayoutView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        // MARK: ????????? ??? ??????
        view.addSubview(likeView)
        likeView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
        }
        
        likeView.addSubview(likeButton)
        likeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.trailing.equalToSuperview().offset(-14)
        }
        
        // MARK: ???????????? ??????
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.height.equalTo(26)
        }
        
        view.addSubview(titleIcon)
        titleIcon.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.width.height.equalTo(24)
        }
        
        view.addSubview(titleButton)
        titleButton.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(titleIcon)
            $0.top.bottom.equalTo(titleLabel)
        }
        
        view.addSubview(categoryView)
        categoryView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        categoryView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(24)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.trailing.equalToSuperview().offset(-32)
            $0.leading.equalToSuperview()
        }
        
        view.addSubview(tagLabel)
        tagLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-32)
            $0.leading.equalToSuperview()
        }
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(tagLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
        
        return view
    }
    
    @objc func tapLikeButton(_ sender: UIButton) {
        let row = sender.tag
        let selectedData = storeList[row]
        print(selectedData)
        sender.isSelected = !sender.isSelected

        // ????????? api ??????
        if sender.isSelected {
            storeList[row].likeCount += 1
        } else {
            storeList[row].likeCount -= 1
        }
        storeList[row].isLike = sender.isSelected
        sender.setTitle("\(storeList[row].likeCount)", for: .normal)
    }
    
    @objc func tapChallengeButton(_ sender: UIButton) {
        let row = sender.tag
        let selectedData = challengeList[row]
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeChallengeViewController") as! HomeChallengeViewController
        vc.challengeData = selectedData
        self.navigationController?.pushViewController(vc, animated: true)
        NotificationCenter.default.post(name: .challengeNoti, object: selectedData)
        
        print(selectedData)
    }
    
    @objc func tapTitleButton(_ sender: UIButton) {
        let row = sender.tag
        let selectedData = storeList[row]
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeStoreViewController") as! HomeStoreViewController
        vc.storeData = selectedData
        vc.isLikeTap = storeList[row].isLike
        self.navigationController?.pushViewController(vc, animated: true)
        NotificationCenter.default.post(name: .storeNoti, object: selectedData)
        
        print(selectedData)
    }
}


//MARK: API
extension HomeViewController {
    
    func reverseGeocode(location: CLLocationCoordinate2D) {
        
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
                let juSoText = "\(siDo) \(guGun)"
                
                DispatchQueue.main.async {
                    self.juSoLabel.text = juSoText
                }
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func weatherAPICall(location: CLLocationCoordinate2D) {
        let url = "https://api.openweathermap.org/data/2.5/weather?"
        
        let params: [String : Any] = [
            "lat": location.latitude,
            "lon": location.longitude,
            "appid": "aa238c81e521f87be610057a5274fec7",
            "units": "metric",
            "lang": "kr"
        ]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).responseJSON { response in

            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                print("result", jsonData)
                let weather = jsonData["weather"][0]["description"].stringValue
                let icon = jsonData["weather"][0]["icon"].stringValue
                let maxTemp = Int(round(jsonData["main"]["temp_max"].doubleValue))
                let minTemp = Int(round(jsonData["main"]["temp_min"].doubleValue))
                let temp = Int(round(jsonData["main"]["temp"].doubleValue))
                
                // ?????? ?????? ??????
                let maxMinTemp = "?????? \(maxTemp)??C / ?????? \(minTemp)??C"
                
                DispatchQueue.main.async { self.weatherIcon.image = UIImage(named: icon)
                    self.maxMinTemperatureLabel.text = maxMinTemp
                    self.weatherLabel.text = weather
                    self.temperatureLabel.text = String(temp)
                }
                
            case .failure(let error):
                print("error", error.localizedDescription)
            }
        }
    }
    /*
    func transcoordWithKakao(lat: Double, lon: Double) {
        let url = "https://dapi.kakao.com/v2/local/geo/transcoord.json?"
        
        let header: HTTPHeaders = [
            "Authorization": "KakaoAK 2fa638d02aece8ee7b03fe0d294c5e4e"
        ]
        
        let params: [String : Any] = [
            "x": lon,
            "y": lat,
            "output_coord":"TM"
        ]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: header).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                let tmX = jsonData["documents"][0]["x"].doubleValue
                let tmY = jsonData["documents"][0]["y"].doubleValue
                
                print("tmX, tmY", tmX, tmY)
                self.getNearbyMsrstnListAirKorea(tmX: tmX, tmY: tmY)
            case .failure(let error):
                print("error", error.localizedDescription)
            }
        }
    }
    
    func getNearbyMsrstnListAirKorea(tmX: Double, tmY: Double) {
        let url = "https://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList?"
        let params: [String : Any] = [
            "serviceKey": BaseConst.AIR_KOREA_KEY,
            "returnType": "json",
            "tmX": tmX,
            "tmY": tmY,
            "ver": "1.0"
        ]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                print("result", jsonData)
            case .failure(let error):
                print("error", error.localizedDescription)
            }
        }
    }
    
    func getMsrstnAcctoRltmMesureDnstyAirKorea(stationName: String) {
        let url = "https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?"
        let params: [String : Any] = [
            "serviceKey": BaseConst.AIR_KOREA_KEY,
            "returnType": "json",
            "numOfRows": 100,
            "pageNo": 1,
            "stationName": stationName,
            "dataTerm":"DAILY",
            "ver": "1.0"
        ]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: BaseConst.headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                print("result", jsonData)
            case .failure(let error):
                print("error", error.localizedDescription)
            }
        }
    }
     */
}


/*
 ????????????
 POP ???????????? (%) "60"
 PTY ???????????? (?????????) "1" (0: ??????, 1: ???, 2: ???/???, 3: ???, 4: ?????????)
 PCP 1?????? ????????? (mm) "2.0mm"
 REH ?????? (%) "90"
 SNO 1?????? ????????? (cm) "????????????"
 SKY ???????????? (?????????) "4" (1: ??????, 3: ????????????, 4:??????)
 TMP 1?????? ?????? (??C) "24"
 TMN ??? ?????? ?????? (??C) ""
 TMX ??? ?????? ?????? (??C) ""
 UUU ??????(??????) (m/s) "-3.1"
 VVV ??????(??????) (m/s) "1.5"
 WAV ?????? (M) "0"
 VEC ?????? (deg) "116"
 WSD ?????? (m/s) "3.6"
 */

/*
 ?????? ?????? ???????????? ?????? ????????????
https://velog.io/@chaeri93/Django-%EA%B8%B0%EC%83%81%EC%B2%AD-%EB%8B%A8%EA%B8%B0%EC%98%88%EB%B3%B4-API-%ED%99%9C%EC%9A%A9%ED%95%98%EA%B8%B0
*/
