//
//  HomeChallengeViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/20.
//

import UIKit

class HomeChallengeViewController: UIViewController {

    @IBOutlet weak var challengeImage: UIImageView!
    
    @IBOutlet weak var challengeTitleLabel: UILabel!
    @IBOutlet weak var challengeSubTitleLabel: UILabel!
    @IBOutlet weak var challengeDescriptionLabel: UILabel!
    
    @IBOutlet weak var challengeDetailImage: UIImageView!
    
    var challengeData: ChallengeData?
    var challengeDetailData: ChallengeDetailData? {
        didSet {
            self.challengeDescriptionLabel.text = self.challengeDetailData?.description
            self.challengeDetailImage.image = UIImage(named: "\(self.challengeDetailData?.imageRoute ?? "")")
        }
    }
    
    private var alertDialog: AlertPopupView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        layOutSetting()
        NotificationCenter.default.addObserver(self,
           selector: #selector(challengeDataNoti(_:)),
           name: .challengeNoti,
           object: nil)

    }
    
    func layOutSetting() {
        self.challengeTitleLabel.text = self.challengeData?.title
        self.challengeSubTitleLabel.text = self.challengeData?.subTitle
        self.challengeImage.image = UIImage(named: "\(self.challengeData?.imageRoute ?? "")")
        
        challengeDetailData = ChallengeDetailData(imageRoute: "challenge_add_image", description: "오늘 외출을 할 예정이신가요? ‘가다’ 앱으로 길을 검색한 뒤, 목적지에 도착해서 하단의 도착 인증하기 버튼을 누르면 추첨을 통해 네이버페이 포인트쿠폰을  드립니다. 여러 번 참여가 가능하지만 당첨은 한 아이디당 한 번만 가능해요.")
    
    }
    
    @objc func challengeDataNoti(_ notification: Notification) {
        print("challengeDataNoti -- ", notification )
        
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapAlertBtn(_ sender: Any) {
        DispatchQueue.main.async {
            [self] in
            
            if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
            alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
            alertDialog.modalTransitionStyle = .crossDissolve
            alertDialog.modalPresentationStyle = .overCurrentContext
            
            alertDialog.descString = "챌린지 알림받기 ON!"
            alertDialog.contentString = "챌린지 오픈일에 알림을 전송해 드릴게요"
            alertDialog.confirmString = "확인"
            alertDialog.confirmClick = { () -> () in  }
            present(alertDialog, animated: true, completion: nil)
        }
        
    }
}
