//
//  DetailPathCell.swift
//  GADA
//
//  Created by leejungchul on 2022/07/01.
//

import Foundation
import UIKit
import SnapKit

class DetailPathCell: UITableViewCell {
    
    var data: SearchPathData? {
        didSet {
            guard let data = data else { return }
            if data.laneCd == "bus" {
                self.laneCd.image = UIImage(named: "busSquare")
                self.verticalLine2.backgroundColor = .black
                self.stationInfoBtn.setImage(UIImage(named: "busInfoBtn"), for: .normal)
                self.stationInfoBtn.isHidden = false
                self.stationInfoBtn.laneCd = "bus"
            } else {
                self.laneCd.image = UIImage(named: "subwaySquare-\(data.laneCd)")
                self.verticalLine2.backgroundColor = UIColor(named: "color-\(data.laneCd)")
                self.stationInfoBtn.isHidden = false
                self.stationInfoBtn.laneCd = "subway"
            }
            self.title.text = data.title
            self.detail.text = data.detail
            self.time.text = data.time
            self.move.text = data.move
            self.stationInfoBtn.layer.cornerRadius = 10
            self.stationInfoBtn.layer.borderWidth = 1
            self.stationInfoBtn.layer.borderColor = UIColor.black.cgColor
            
            var stationListLabel = ""
            for (i,v) in data.stationList.enumerated() {
                if i == data.stationList.count - 1 {
                    stationListLabel += "\(v)"
                } else {
                    stationListLabel += "\(v)\n"
                }
            }
            
            self.stationList.text = stationListLabel
        }
    }
    
    var postData: SearchPathData? {
        didSet {
            guard let data = postData else { return }
            if data.laneCd == "bus" {
                self.verticalLine1.backgroundColor = .black
                self.stationInfoBtn.setImage(UIImage(named: "busInfoBtn"), for: .normal)
                self.stationInfoBtn.laneCd = "bus"
            } else if data.laneCd == "walk" {
                
            } else {
                self.stationInfoBtn.setImage(UIImage(named: "subwayTransferBtn"), for: .normal)
                self.stationInfoBtn.isTransfer = true
                self.verticalLine1.backgroundColor = UIColor(named: "color-\(data.laneCd)")
                self.stationInfoBtn.laneCd = "subway"
            }
        }
    }
    
    fileprivate let verticalLine1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let verticalLine2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let laneView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    fileprivate let laneCd: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    fileprivate let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Bold", size: 16.0)
        label.text = "title"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let detail: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        label.text = "detail"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let time: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        label.text = "time"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let line: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let move: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        label.text = "move"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let dropDownIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "dropDown")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    fileprivate let stationList: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 12.0)
        label.text = "stationList"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let horizentalLine1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let stationInfoBtn: CustomButton = {
        let button = CustomButton()
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "subwayStationBtn"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(container)
        container.addSubview(verticalLine1)
        container.addSubview(verticalLine2)
        container.addSubview(laneView)
        laneView.addSubview(laneCd)
        container.addSubview(title)
        container.addSubview(detail)
        container.addSubview(time)
        container.addSubview(line)
        container.addSubview(move)
        container.addSubview(dropDownIcon)
        container.addSubview(stationList)
        container.addSubview(stationInfoBtn)
        
        container.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(contentView)
        }
        laneView.snp.makeConstraints {
            $0.top.equalTo(container).offset(5)
            $0.leading.equalTo(container).offset(30)
            $0.width.height.equalTo(22)
        }
        
        verticalLine1.snp.makeConstraints {
            $0.top.equalTo(container)
            $0.bottom.equalTo(laneView.snp.top)
            $0.width.equalTo(1)
            $0.centerX.equalTo(laneView)
        }
        
        verticalLine2.snp.makeConstraints {
            $0.top.equalTo(laneView.snp.bottom)
            $0.bottom.equalTo(container)
            $0.width.equalTo(1)
            $0.centerX.equalTo(laneView)
        }
        
        laneCd.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(laneView)
        }
        
        title.snp.makeConstraints {
            $0.centerY.equalTo(laneCd)
            $0.leading.equalTo(laneCd.snp.trailing).offset(10)
            $0.height.equalTo(16)
        }
        
        stationInfoBtn.snp.makeConstraints {
            $0.centerY.equalTo(title)
            $0.height.equalTo(20)
            $0.trailing.equalTo(container).offset(-30)
        }
        
        detail.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(5)
            $0.leading.equalTo(title)
            $0.height.equalTo(15)
        }
        
        time.snp.makeConstraints {
            $0.top.equalTo(detail.snp.bottom).offset(5)
            $0.leading.equalTo(title)
            $0.height.equalTo(15)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(time).offset(2)
            $0.bottom.equalTo(time).offset(-2)
            $0.leading.equalTo(time.snp.trailing).offset(8)
            $0.width.equalTo(1)
        }
        
        move.snp.makeConstraints {
            $0.top.equalTo(time)
            $0.leading.equalTo(line.snp.trailing).offset(7)
            $0.height.equalTo(15)
        }
        
        stationList.snp.makeConstraints {
            $0.top.equalTo(time.snp.bottom).offset(10)
            $0.leading.equalTo(title).offset(0)
            $0.trailing.bottom.equalTo(container).offset(-10)
        }
        
        dropDownIcon.snp.makeConstraints {
            $0.top.bottom.equalTo(move)
            $0.leading.equalTo(move.snp.trailing).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DetailWalkPathCell: UITableViewCell {
    
    var data: SearchPathData? {
        didSet {
            guard let data = data else { return }
   
            self.verticalImage.image = UIImage(named: "dottedLine")
            self.detail.text = data.detail
            self.time.text = "\(data.time)분"
            self.move.text = "\(data.move)m 이동"
            self.stationInfoBtn.isHidden = true
        }
    }
    
    var postData: SearchPathData? {
        didSet {
            guard let data = postData else { return }
            if data.laneCd == "bus" {
                self.title.text = data.stationList[data.stationList.count-1]
                self.verticalLine.backgroundColor = .black
                self.laneCd.layer.borderColor = UIColor.black.cgColor
                self.stationInfoBtn.isHidden = true
            } else {
                self.title.text = data.stationList[data.stationList.count-1]
                self.verticalLine.backgroundColor = UIColor(named: "color-\(data.laneCd)")
                self.laneCd.layer.borderColor = UIColor(named: "color-\(data.laneCd)")?.cgColor
                self.stationInfoBtn.isHidden = false
                self.stationInfoBtn.layer.cornerRadius = 10
                self.stationInfoBtn.layer.borderWidth = 1
                self.stationInfoBtn.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    var startWalk: [String]? {
        didSet {
            guard let data = startWalk else { return }
            self.title.text = data[0]
            self.detail.text = data[1]
            self.verticalLine.backgroundColor = .clear
            self.laneCd.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    var endTransfer: [String]? {
        didSet {
            guard let data = endTransfer else { return }
            if data[1] == "bus" {
                self.detail.text = "도보"
            } else {
                self.detail.text = "\(data[0])번 출구"
            }
        }
    }
    
    fileprivate let verticalLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let verticalImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    fileprivate let laneView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    fileprivate let laneCd: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Bold", size: 16.0)
        label.text = "title"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let detail: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        label.text = "detail"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let time: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        label.text = "time"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let line: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let move: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        label.text = "move"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let stationList: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 12.0)
        label.text = "stationList"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let stationInfoBtn: CustomButton = {
        let button = CustomButton()
        button.backgroundColor = .clear
        button.setTitle("  역정보  ", for: .normal)
        button.titleLabel?.font = UIFont(name: "NotoSansCJKkr-Regular", size: 12.0)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(container)
        container.addSubview(verticalLine)
        container.addSubview(verticalImage)
        container.addSubview(laneView)
        laneView.addSubview(laneCd)
        container.addSubview(title)
        container.addSubview(detail)
        container.addSubview(time)
        container.addSubview(line)
        container.addSubview(move)
        container.addSubview(stationList)
        container.addSubview(stationInfoBtn)
        
        container.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(contentView)
        }
        
        laneView.snp.makeConstraints {
            $0.top.equalTo(container).offset(5)
            $0.leading.equalTo(container).offset(30)
            $0.width.height.equalTo(22)
        }
        
        verticalLine.snp.makeConstraints {
            $0.top.equalTo(container)
            $0.bottom.equalTo(laneCd.snp.top)
            $0.width.equalTo(1)
            $0.centerX.equalTo(laneView)
        }
        
        verticalImage.snp.makeConstraints {
            $0.top.equalTo(laneView.snp.bottom).offset(5)
            $0.bottom.equalTo(container)
            $0.width.equalTo(1)
            $0.centerX.equalTo(laneView)
        }
        
        laneCd.snp.makeConstraints {
            $0.centerX.centerY.equalTo(laneView)
            $0.width.height.equalTo(12)
        }
        
        title.snp.makeConstraints {
            $0.centerY.equalTo(laneCd)
            $0.leading.equalTo(laneCd.snp.trailing).offset(10)
            $0.height.equalTo(16)
        }
        
        stationInfoBtn.snp.makeConstraints {
            $0.centerY.equalTo(title)
            $0.height.equalTo(20)
            $0.trailing.equalTo(container).offset(-30)
        }
        
        detail.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(5)
            $0.leading.equalTo(title)
            $0.height.equalTo(15)
        }
        
        time.snp.makeConstraints {
            $0.top.equalTo(detail.snp.bottom).offset(5)
            $0.leading.equalTo(title)
            $0.height.equalTo(15)
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(time).offset(2)
            $0.bottom.equalTo(time).offset(-2)
            $0.leading.equalTo(time.snp.trailing).offset(8)
            $0.width.equalTo(1)
        }
        
        move.snp.makeConstraints {
            $0.top.equalTo(time)
            $0.leading.equalTo(line.snp.trailing).offset(7)
            $0.height.equalTo(15)
        }
        
        stationList.snp.makeConstraints {
            $0.top.equalTo(time.snp.bottom).offset(10)
            $0.leading.equalTo(title).offset(0)
            $0.trailing.bottom.equalTo(container).offset(-10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DetailEndPathCell: UITableViewCell {
    
    var data: [String]? {
        didSet {
            guard let data = data else { return }
            self.title.text = data[1]
        }
    }
        
    fileprivate let laneView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    fileprivate let laneCd: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let laneCd2: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Bold", size: 16.0)
        label.text = "title"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(container)
        container.addSubview(laneView)
        laneView.addSubview(laneCd)
        laneView.addSubview(laneCd2)
        container.addSubview(title)
        
        container.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(contentView)
        }
        laneView.snp.makeConstraints {
            $0.top.equalTo(container).offset(5)
            $0.leading.equalTo(container).offset(30)
            $0.height.width.equalTo(22)
        }
        laneCd.snp.makeConstraints {
            $0.centerX.centerY.equalTo(laneView)
            $0.width.height.equalTo(12)
        }
        laneCd2.snp.makeConstraints {
            $0.centerX.centerY.equalTo(laneCd)
            $0.width.height.equalTo(6)
        }
        title.snp.makeConstraints {
            $0.centerY.equalTo(laneCd)
            $0.leading.equalTo(laneCd.snp.trailing).offset(10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
