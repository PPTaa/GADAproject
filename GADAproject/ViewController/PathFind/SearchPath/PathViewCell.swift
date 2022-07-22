//
//  PathViewCellTest.swift
//  GADA
//
//  Created by leejungchul on 2022/06/30.
//

import Foundation
import UIKit
import SnapKit

class PathViewCell: UITableViewCell {
    
    // 경로 아이콘
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "icRouteKind_1")
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    // 소요 시간 표기
    let time: UILabel = {
        let text = UILabel()
        text.font = UIFont.pretendard(type: .bold, size: 24)
        text.textColor = UIColor.textPrimary
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 환승 횟수 표기
    let transferNum: UILabel = {
        let text = UILabel()
        text.font = UIFont.pretendard(type: .medium, size: 14)
        text.textColor = UIColor.textSecondary
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 사이 선
    let line1: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.textSecondary
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    // 보행 시간 표기
    let walkTime: UILabel = {
        let text = UILabel()
        text.font = UIFont.pretendard(type: .medium, size: 14)
        text.textColor = UIColor.textSecondary
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 사이 선
    let line2: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.textSecondary
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    // 도착 예상 시간 표기
    let endTime: UILabel = {
        let text = UILabel()
        text.font = UIFont.pretendard(type: .medium, size: 14)
        text.textColor = UIColor.textSecondary
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    // 세부 경로 뷰
    let detailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // 라인이 들어가는 뷰
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // detail, container 사이 선
    let line3: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.clear
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    // 마지막 셀 구분 선
    let line4: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.baseBorder
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    override func awakeFromNib() {
        print("awakeFromNib()")
        contentView.addSubview(icon)
        icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        
        contentView.addSubview(time)
        time.leadingAnchor.constraint(equalTo: icon.leadingAnchor, constant: 0).isActive = true
        time.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10).isActive = true
        
        contentView.addSubview(transferNum)
        transferNum.leadingAnchor.constraint(equalTo: time.trailingAnchor, constant: 8).isActive = true
        transferNum.bottomAnchor.constraint(equalTo: time.bottomAnchor, constant: -3).isActive = true
        
        contentView.addSubview(line1)
        line1.leadingAnchor.constraint(equalTo: transferNum.trailingAnchor, constant: 5).isActive = true
        line1.topAnchor.constraint(equalTo: transferNum.topAnchor, constant: 3).isActive = true
        line1.bottomAnchor.constraint(equalTo: transferNum.bottomAnchor, constant: -3).isActive = true
        line1.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        contentView.addSubview(walkTime)
        walkTime.leadingAnchor.constraint(equalTo: line1.trailingAnchor, constant: 5).isActive = true
        walkTime.bottomAnchor.constraint(equalTo: time.bottomAnchor, constant: -3).isActive = true
        
        contentView.addSubview(line2)
        line2.leadingAnchor.constraint(equalTo: walkTime.trailingAnchor, constant: 5).isActive = true
        line2.topAnchor.constraint(equalTo: line1.topAnchor, constant: 0).isActive = true
        line2.bottomAnchor.constraint(equalTo: line1.bottomAnchor, constant: 0).isActive = true
        line2.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        contentView.addSubview(endTime)
        endTime.leadingAnchor.constraint(equalTo: line2.trailingAnchor, constant: 5).isActive = true
        endTime.bottomAnchor.constraint(equalTo: time.bottomAnchor, constant: -3).isActive = true
        
        contentView.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        contentView.addSubview(detailView)
        detailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        detailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        detailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        contentView.addSubview(line3)
        line3.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        line3.bottomAnchor.constraint(equalTo: detailView.topAnchor, constant: 0).isActive = true
        line3.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        line3.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        line3.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        contentView.addSubview(line4)
        line4.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalTo(contentView.snp.leading).offset(16)
            $0.trailing.bottom.equalTo(contentView)
        }
    }
    
    override func prepareForReuse() {
        print("prepareForReuse()")
        containerView.removeAllSubViews()
        detailView.removeAllSubViews()
    }
    
    func addLineView(idx: Int, lnCd: String, length: CGFloat, time: String) {
        
        let lineView = UIView()
        let lineLabel = UILabel()
    
        lineLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 9.5)
//        lineLabel.text = time
        lineLabel.text = ""
        lineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        lineView.layer.cornerRadius = 2
        lineView.widthAnchor.constraint(equalToConstant: length).isActive = true
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        if lnCd == "bus" {
            lineView.backgroundColor = UIColor.baseGray600
            lineView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        } else if lnCd == "walk" {
            lineView.backgroundColor = UIColor.baseGray300
            lineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        } else {
            lineView.backgroundColor = UIColor(named: "color-\(lnCd)") ?? .baseGray600
            lineView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        }
        
        
        if idx == 0 {
            containerView.addSubview(lineLabel)
            containerView.addSubview(lineView)
            
            lineLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
            lineLabel.centerXAnchor.constraint(equalTo: lineView.centerXAnchor, constant: 0).isActive = true
            
            lineView.topAnchor.constraint(equalTo: lineLabel.bottomAnchor, constant: 3).isActive = true
            lineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        } else {
            let lastView = containerView.subviews.last
            
            containerView.addSubview(lineLabel)
            containerView.addSubview(lineView)
            
            lineLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
            lineLabel.centerXAnchor.constraint(equalTo: lineView.centerXAnchor, constant: 0).isActive = true
            
            lineView.centerYAnchor.constraint(equalTo: lastView!.centerYAnchor, constant: 0).isActive = true
            lineView.leadingAnchor.constraint(equalTo: lastView!.trailingAnchor, constant: 0).isActive = true
        }
    }
    
    func addDetailView(idx: Int, station: String, description: String, icon: String) {
        print(idx, station, description, icon)
        let detailIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            if icon == "bus" {
                imageView.image = UIImage(named: "circle_bus_24")
            } else if icon == "end" {
                imageView.image = UIImage(named: "circle_none_24")
            } else {
                imageView.image = UIImage(named: "circle_line_\(icon)_24") ?? UIImage(named: "circle_none_24")
            }
            return imageView
        }()
        
        let endIcon: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.baseGray300
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let detailStation: UILabel = {
            let label = UILabel()
            label.font = UIFont.pretendard(type: .medium, size: 14)
            label.textColor = UIColor.textPrimary
            label.text = station
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let detailDescription: UILabel = {
            let label = UILabel()
            label.font = UIFont.pretendard(type: .medium, size: 14)
            label.textColor = UIColor.textSecondary
            label.text = description
            label.textAlignment = .right
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        if idx == 0 {
            detailView.addSubview(detailIcon)
            detailView.addSubview(detailStation)
            detailView.addSubview(detailDescription)
            
            detailIcon.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 10).isActive = true
            detailIcon.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 0).isActive = true
            detailIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
            
            detailStation.centerYAnchor.constraint(equalTo: detailIcon.centerYAnchor, constant: 0).isActive = true
            detailStation.leadingAnchor.constraint(equalTo: detailIcon.trailingAnchor, constant: 10).isActive = true
            
            detailDescription.centerYAnchor.constraint(equalTo: detailStation.centerYAnchor).isActive = true
            detailDescription.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -16).isActive = true
            
            detailIcon.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -10).isActive = true
            
        } else {
            let subviewCount = detailView.subviews.count
            
            let lastView = detailView.subviews[subviewCount - 1]
//            let secondView = detailView.subviews[subviewCount - 2]
            let thirdView = detailView.subviews[subviewCount - 3]
            
            let lastConst = detailView.constraints.last!
            
            detailView.addSubview(detailIcon)
            detailView.addSubview(detailStation)
            detailView.addSubview(detailDescription)
            
            detailView.removeConstraint(lastConst)
            
            detailIcon.topAnchor.constraint(equalTo: thirdView.bottomAnchor, constant: 10).isActive = true
            detailIcon.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 0).isActive = true
            detailIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
            
            detailStation.centerYAnchor.constraint(equalTo: detailIcon.centerYAnchor, constant: 0).isActive = true
            detailStation.leadingAnchor.constraint(equalTo: detailIcon.trailingAnchor, constant: 10).isActive = true
            
            detailDescription.centerYAnchor.constraint(equalTo: detailStation.centerYAnchor).isActive = true
            detailDescription.trailingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
            
            detailIcon.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -10).isActive = true
            
            if icon == "end" {
                detailView.addSubview(endIcon)
                endIcon.snp.makeConstraints {
                    $0.centerX.equalTo(detailIcon)
                    $0.top.equalTo(detailView)
                    $0.bottom.equalTo(detailIcon.snp.top).offset(4)
                }
            }

        }
    }
}

