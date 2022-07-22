//
//  HomeStoreViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/20.
//

import UIKit

class HomeStoreViewController: UIViewController {
    @IBOutlet weak var storeImage: UIImageView!
    
    @IBOutlet weak var storeLikeCountButton: UIButton!
    @IBOutlet weak var storeTitleLabel: UILabel!
    @IBOutlet weak var storeDescriptionLabel: UILabel!
    
    @IBOutlet weak var storeCategoryView: UIView!
    @IBOutlet weak var storeCategoryLabel: UILabel!
    
    @IBOutlet weak var storeLocationLabel: UILabel!
    @IBOutlet weak var storePhoneLabel: UILabel!
    @IBOutlet weak var storeTimeLabel: UILabel!
    
    @IBOutlet weak var storeExitLabel: UILabel!
    @IBOutlet weak var storeInfoLabel: UILabel!
    @IBOutlet weak var storeParkingLabel: UILabel!
    @IBOutlet weak var storeConvenienceLabel: UILabel!
    
    var storeData: StoreData?
    var isLikeTap: Bool?
    var storeDetailData: StoreDetailData? {
        didSet {
            self.storeLocationLabel.text = self.storeDetailData?.location
            self.storePhoneLabel.attributedText = NSAttributedString(string: self.storeDetailData?.phone ?? "", attributes: underlineAttribute)
            self.storeTimeLabel.text = self.storeDetailData?.time
            self.storeExitLabel.text = self.storeDetailData?.exit
            self.storeInfoLabel.text = self.storeDetailData?.info
            self.storeParkingLabel.text = self.storeDetailData?.parking
            self.storeConvenienceLabel.text = self.storeDetailData?.convenience
        }
    }
    
    let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layOutSetting()
        storeCategoryView.roundCorner(radius: 12)
        NotificationCenter.default.addObserver(self,
           selector: #selector(storeDataNoti(_:)),
           name: .storeNoti,
           object: nil)


    }
    
    func layOutSetting() {
        
        self.storeImage.image = UIImage(named: "\(self.storeData?.storeImageRoute ?? "")")
        self.storeTitleLabel.text = self.storeData?.storeTitle
        self.storeDescriptionLabel.text = self.storeData?.storeDescription
        self.storeCategoryLabel.text = self.storeData?.storeCategory
        self.storeLikeCountButton.setTitle("\(self.storeData?.likeCount ?? 0)", for: .normal)
        self.storeLikeCountButton.isSelected = isLikeTap ?? false
        
        if self.storeData?.storeTitle == "페이퍼넛츠" {
            self.storeDetailData = StoreDetailData(
                location: "서울 서대문구 거북골로24길 37-8 1층",
                phone: "02 - 6408 - 7799",
                time: """
                화 - 금 11 AM - 7 PM
                토 - 일 11 AM - 6 PM (매주 월요일 휴무)
                """,
                exit: "턱이 없고 완만해 휠체어 입출입 편리",
                info: "음성 및 문자 안내 서비스 지원",
                parking: "주차 가능",
                convenience: "휠체어 화장실 인근 위치")
        } else if self.storeData?.storeTitle == "잇테이블" {
            self.storeDetailData = StoreDetailData(
                location: "서울 강남구 역삼로14길 8",
                phone: "02 - 552 - 6662",
                time: """
                월 - 금 8:00 - 24:00
                토 - 일 10:00 - 24:00
                """,
                exit: "폭이넓고 경사가 없어  휠체어 입출입 편리",
                info: "-",
                parking: "-",
                convenience: "입식 테이블 및 넓은 이동 공간")
        } else if self.storeData?.storeTitle == "시오 구로NC백화점" {
            self.storeDetailData = StoreDetailData(
                location: "서울 구로구 구로중앙로 152",
                phone: "02 - 6923 - 2438",
                time: """
                월 - 금 8:00 - 24:00
                토 - 일 10:00 - 24:00
                """,
                exit: "경사, 단차가 없고 폭이 넓어 휠체어 입출입 편리",
                info: "-",
                parking: "장애인 주차장 보유",
                convenience: "엘리베이터, 장애인 화장실 보유")
        } else {
            self.storeDetailData = StoreDetailData(
                location: "서울 서대문구 거북골로24길 37-8 1층",
                phone: "02 - 6408 - 7799",
                time: """
                화 - 금 11 AM - 7 PM
                토 - 일 11 AM - 6 PM (매주 월요일 휴무)
                """,
                exit: "턱이 없고 완만해 휠체어 입출입 편리",
                info: "음성 및 문자 안내 서비스 지원",
                parking: "주차 가능",
                convenience: "휠체어 화장실 인근 위치")
            
        }
        
    }
    
    @objc func storeDataNoti(_ notification: Notification) {
        print("storeDataNoti -- ", notification )
        
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapPhoneCallButton(_ sender: UIButton) {
        print(#function)
        guard let phone = storeDetailData?.phone else { return }
        let number = phone.replace(target: " ", withString: "")
        print(number)
        UsefulUtils.callTo(phoneNumber: number)
    }
    
    @IBAction func tapLikeButton(_ sender: UIButton) {
        // 좋아요 api 요청
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            storeData?.likeCount += 1
        } else {
            storeData?.likeCount -= 1
        }
        sender.setTitle("\(storeData?.likeCount ?? 0)", for: .normal)
    }
    


}
