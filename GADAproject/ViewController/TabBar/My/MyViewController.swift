//
//  MyViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var questionStackView: UIStackView!
    
    let dateFormatter = DateFormatter()
    
//    let myData = DataShare.shared().profileDao

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        let convertDate = dateFormatter.string(from: Date())
        
        // Do any additional setup after loading the view.
        dataSetting()
    }
    
    
    
    func dataSetting() {
        let myData = DataShare.shared().profileDao
        
        let subjectDataList = DataShare.shared().subjectDataList
        let multipleDataList = DataShare.shared().multipleDataList
        
        print("multipleDataList -- ", multipleDataList)
        
        UsefulUtils.roundingCorner(view: self.profileImageView)
        self.nickNameLabel.text = myData?.name
        self.phoneNumberLabel.text = myData?.cell_num
        if let dataList = subjectDataList {
            for (idx, subData) in dataList.enumerated() {
                let view = makeSubjectQuestionView(idx: idx, date: subData.date, title: subData.title, answer1: subData.answer1, answer2: subData.answer2)
                self.questionStackView.addArrangedSubview(view)
            }
        }
        if let dataList = multipleDataList {
            for (idx, multiData) in dataList.enumerated() {
                let view = makeMultipleQuestionView(idx: idx, date: multiData.date, title: multiData.title, answer: multiData.allQuestion, selectAnswer: multiData.selectNum, percentData: multiData.percentData)
                self.questionStackView.addArrangedSubview(view)
            }
        }
    }
    
    private func makeSubjectQuestionView(idx: Int, date: String, title: String, answer1: String, answer2: String) -> UIView {
        let view = UIView()
        view.layer.backgroundColor = UIColor.clear.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "나의 가다"
        titleLabel.textColor = .textPrimary
        titleLabel.font = UIFont.pretendard(type: .bold, size: 16)
        
        let pencilImage = UIImageView()
        pencilImage.image = UIImage(named: "pencil_icon")
        
        let dateLabel = UILabel()
        dateLabel.text = "\(date)"
        dateLabel.textColor = .textSecondary
        dateLabel.font = UIFont.pretendard(type: .medium, size: 14)
        
        
        let questionTitleLabel = UILabel()
        questionTitleLabel.text = title
        questionTitleLabel.textColor = .textPrimary
        questionTitleLabel.numberOfLines = 0
        questionTitleLabel.font = UIFont.pretendard(type: .bold, size: 18)

        let imageView = UIImageView()
        imageView.image = UIImage(named: "footPrint_Image")
        
        let answerTextField1 = UITextField()
        answerTextField1.addLeftPadding()
        answerTextField1.isEnabled = false
        answerTextField1.backgroundColor = .baseBackground
        answerTextField1.text = answer1
        answerTextField1.borderStyle = .none
        answerTextField1.layer.borderWidth = 1
        answerTextField1.layer.borderColor = UIColor.inputDefault?.cgColor
        
        let answerTextField2 = UITextField()
        answerTextField2.addLeftPadding()
        answerTextField2.isEnabled = false
        answerTextField2.backgroundColor = .baseBackground
        answerTextField2.text = answer2
        answerTextField2.borderStyle = .none
        answerTextField2.layer.borderWidth = 1
        answerTextField2.layer.borderColor = UIColor.inputDefault?.cgColor
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(30)
            $0.height.equalTo(26)
        }
        
        view.addSubview(pencilImage)
        pencilImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
        }
        
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(pencilImage.snp.trailing).offset(4)
            $0.height.equalTo(24)
            $0.centerY.equalTo(pencilImage)
        }
        
        view.addSubview(questionTitleLabel)
        questionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(1)
            $0.leading.equalTo(pencilImage)
            $0.trailing.equalToSuperview().offset(-108)
        }
        
        view.addSubview(imageView)
        view.addSubview(answerTextField1)
        answerTextField1.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(questionTitleLabel.snp.bottom).offset(175)
            $0.height.equalTo(44)
        }
        
        view.addSubview(answerTextField2)
        answerTextField2.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(answerTextField1.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(44)
        }
        
        imageView.snp.makeConstraints {
            $0.bottom.equalTo(answerTextField1.snp.bottom).offset(-12)
            $0.trailing.equalToSuperview().offset(12)
        }
        
        
        return view
    }
    
    private func makeMultipleQuestionView(idx: Int, date: String, title: String, answer: [String], selectAnswer: Int, percentData: [Double]) -> UIView {
        let view = UIView()
        view.layer.backgroundColor = UIColor.clear.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "나의 가다"
        titleLabel.textColor = .textPrimary
        titleLabel.font = UIFont.pretendard(type: .bold, size: 16)
        
        let imageContainerView = UIView()
        imageContainerView.backgroundColor = .clear
        imageContainerView.layer.cornerRadius = 10
        imageContainerView.layer.borderColor = UIColor.clear.cgColor
        imageContainerView.layer.borderWidth = 1
        imageContainerView.layer.masksToBounds = true
        
        let backImage = UIImageView()
        backImage.image = UIImage(named: "card_image_\(selectAnswer+1)")
        backImage.contentMode = .scaleAspectFill
        
        let coverView = UIView()
        coverView.backgroundColor = .black.withAlphaComponent(0.3)
        
        
        let pencilImage = UIImageView()
        pencilImage.image = UIImage(named: "pencil_icon")
        
        let dateLabel = UILabel()
        dateLabel.text = "\(date)"
        dateLabel.textColor = .white
        dateLabel.font = UIFont.pretendard(type: .medium, size: 14)
        
        
        let questionTitleLabel = UILabel()
        questionTitleLabel.text = title
        questionTitleLabel.textColor = .white
        questionTitleLabel.numberOfLines = 0
        questionTitleLabel.font = UIFont.pretendard(type: .bold, size: 18)
        
        let questionAnswerLabel = UILabel()
        questionAnswerLabel.text = "A. \(answer[selectAnswer])"
        questionAnswerLabel.textColor = .white
        questionAnswerLabel.numberOfLines = 0
        questionAnswerLabel.font = UIFont.pretendard(type: .medium, size: 16)
        
        let answerView1 = UIView()
        answerView1.layer.cornerRadius = 10
        answerView1.layer.borderColor = UIColor.clear.cgColor
        answerView1.layer.borderWidth = 1
        answerView1.layer.masksToBounds = true
        answerView1.backgroundColor = .baseBorder
        
        let answerView1Percent = UIView()
        answerView1Percent.layer.cornerRadius = 10
        answerView1Percent.layer.borderColor = UIColor.clear.cgColor
        answerView1Percent.layer.borderWidth = 1
        answerView1Percent.layer.masksToBounds = true
        answerView1Percent.backgroundColor = .primaryGreen600
        
        let answerTitleLabel1 = UILabel()
        answerTitleLabel1.text = answer[0]
        answerTitleLabel1.textColor = .textPrimary
        
        let answerPercentLabel1 = UILabel()
        answerPercentLabel1.text = "\(percentData[0])%"
        answerPercentLabel1.textColor = .textSecondary
        
        let answerView2 = UIView()
        answerView2.layer.cornerRadius = 10
        answerView2.layer.borderColor = UIColor.clear.cgColor
        answerView2.layer.borderWidth = 1
        answerView2.layer.masksToBounds = true
        answerView2.backgroundColor = .baseBorder
        
        let answerView2Percent = UIView()
        answerView2Percent.layer.cornerRadius = 10
        answerView2Percent.layer.borderColor = UIColor.clear.cgColor
        answerView2Percent.layer.borderWidth = 1
        answerView2Percent.layer.masksToBounds = true
        answerView2Percent.backgroundColor = .primaryGreen600
        
        let answerTitleLabel2 = UILabel()
        answerTitleLabel2.text = answer[1]
        answerTitleLabel2.textColor = .textPrimary
        
        let answerPercentLabel2 = UILabel()
        answerPercentLabel2.text = "\(percentData[1])%"
        answerPercentLabel2.textColor = .textSecondary
        
        let answerView3 = UIView()
        answerView3.layer.cornerRadius = 10
        answerView3.layer.borderColor = UIColor.clear.cgColor
        answerView3.layer.borderWidth = 1
        answerView3.layer.masksToBounds = true
        answerView3.backgroundColor = .baseBorder
        
        let answerView3Percent = UIView()
        answerView3Percent.layer.cornerRadius = 10
        answerView3Percent.layer.borderColor = UIColor.clear.cgColor
        answerView3Percent.layer.borderWidth = 1
        answerView3Percent.layer.masksToBounds = true
        answerView3Percent.backgroundColor = .primaryGreen600
        
        let answerTitleLabel3 = UILabel()
        answerTitleLabel3.text = answer[2]
        answerTitleLabel3.textColor = .textPrimary
        
        let answerPercentLabel3 = UILabel()
        answerPercentLabel3.text = "\(percentData[2])%"
        answerPercentLabel3.textColor = .textSecondary
        
        let answerView4 = UIView()
        answerView4.layer.cornerRadius = 10
        answerView4.layer.borderColor = UIColor.clear.cgColor
        answerView4.layer.borderWidth = 1
        answerView4.layer.masksToBounds = true
        answerView4.backgroundColor = .baseBorder
        
        let answerView4Percent = UIView()
        answerView4Percent.layer.cornerRadius = 10
        answerView4Percent.layer.borderColor = UIColor.clear.cgColor
        answerView4Percent.layer.borderWidth = 1
        answerView4Percent.layer.masksToBounds = true
        answerView4Percent.backgroundColor = .primaryGreen600
        
        let answerTitleLabel4 = UILabel()
        answerTitleLabel4.text = answer[3]
        answerTitleLabel4.textColor = .textPrimary
        
        let answerPercentLabel4 = UILabel()
        answerPercentLabel4.text = "\(percentData[3])%"
        answerPercentLabel4.textColor = .textSecondary

        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(30)
            $0.height.equalTo(26)
        }
        
        view.addSubview(imageContainerView)
        imageContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(163)
        }
        
        imageContainerView.addSubview(backImage)
        backImage.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        imageContainerView.addSubview(coverView)
        coverView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        imageContainerView.addSubview(pencilImage)
        imageContainerView.addSubview(dateLabel)
        
        pencilImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(dateLabel)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(pencilImage.snp.trailing).offset(4)
            $0.height.equalTo(24)
            $0.top.equalToSuperview().offset(18)
        }
        
        imageContainerView.addSubview(questionTitleLabel)
        questionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(1)
            $0.leading.equalTo(pencilImage)
            $0.trailing.equalToSuperview().offset(-120)
        }
        
        imageContainerView.addSubview(questionAnswerLabel)
        questionAnswerLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-18)
            $0.bottom.equalToSuperview().offset(-14)
        }
        
        view.addSubview(answerView1)
        answerView1.snp.makeConstraints {
            $0.leading.trailing.equalTo(imageContainerView)
            $0.top.equalTo(imageContainerView.snp.bottom).offset(21)
            $0.height.equalTo(56)
        }
        answerView1.addSubview(answerView1Percent)
        answerView1Percent.snp.makeConstraints {
            let width = (self.view.frame.width - 32.0) * percentData[0] / 100
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(width)// 값 변동
        }
        answerView1.addSubview(answerTitleLabel1)
        answerTitleLabel1.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
        }
        answerView1.addSubview(answerPercentLabel1)
        answerPercentLabel1.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        view.addSubview(answerView2)
        answerView2.snp.makeConstraints {
            $0.leading.trailing.equalTo(answerView1)
            $0.top.equalTo(answerView1.snp.bottom).offset(8)
            $0.height.equalTo(56)
        }
        answerView2.addSubview(answerView2Percent)
        answerView2Percent.snp.makeConstraints {
            let width = (self.view.frame.width - 32.0) * percentData[1] / 100
            print("width --- \(self.view.frame.width)")
            print("width --- \(width)")
            print("width --- \(self.view.frame.width)")
            print("width --- \(self.view.frame.width)")
            print("width --- \(self.view.frame.width)")
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(width) // 값 변동
        }
        answerView2.addSubview(answerTitleLabel2)
        answerTitleLabel2.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
        }
        answerView2.addSubview(answerPercentLabel2)
        answerPercentLabel2.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        view.addSubview(answerView3)
        answerView3.snp.makeConstraints {
            $0.leading.trailing.equalTo(answerView2)
            $0.top.equalTo(answerView2.snp.bottom).offset(8)
            $0.height.equalTo(56)
        }
        answerView3.addSubview(answerView3Percent)
        answerView3Percent.snp.makeConstraints {
            let width = (self.view.frame.width - 32.0) * percentData[2] / 100
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(width) // 값 변동
        }
        answerView3.addSubview(answerTitleLabel3)
        answerTitleLabel3.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
        }
        answerView3.addSubview(answerPercentLabel3)
        answerPercentLabel3.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        view.addSubview(answerView4)
        answerView4.snp.makeConstraints {
            $0.leading.trailing.equalTo(answerView3)
            $0.top.equalTo(answerView3.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-20)
        }
        answerView4.addSubview(answerView4Percent)
        answerView4Percent.snp.makeConstraints {
            let width = (self.view.frame.width - 32.0) * percentData[3] / 100
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(width) // 값 변동
        }
        answerView4.addSubview(answerTitleLabel4)
        answerTitleLabel4.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
        }
        answerView4.addSubview(answerPercentLabel4)
        answerPercentLabel4.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        
        
        return view
    }
    

}
