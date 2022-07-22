//
//  InfoCell.swift
//  GADA
//
//  Created by leejungchul on 2022/07/11.
//

import Foundation
import UIKit
import SnapKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var stationInfoImage: UIImageView!
    @IBOutlet weak var expandImageBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UsefulUtils.roundingCorner(view: expandImageBtn)
        UsefulUtils.shadowCorner(view: expandImageBtn, shadowOpacity: 0.25)
    }
    
}


// UITableView 코드로 작성
class InfoCell: UITableViewCell {
    
    static let cellId = "InfoCell"
    
    let floor: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.textPrimary
        label.font = UIFont.pretendard(type: .medium, size: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.baseBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.baseBorder
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var detailCount = 0
    var locationCount = 0
    
    override func awakeFromNib() {
        print("awakeFromNib()")
        setting()
    }
    override func prepareForReuse() {
        print("prepareForReuse()")
        containerView.removeAllSubViews()
    }
    func setting() {
        contentView.backgroundColor = .baseBackground
        contentView.addSubview(floor)
        contentView.addSubview(containerView)
        contentView.addSubview(lineView)
        floor.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(25)
            $0.top.equalToSuperview().offset(20)
        }
//        floor.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
//        floor.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(floor.snp.bottom)
            $0.bottom.equalTo(lineView.snp.top)
        }
        
        lineView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    // 데이터 겹치지 않도록 여러줄 처리 필요(완)
    func addDetailLabel(detail: String, location: String, loop: Int ,isOrient: Bool = false) {
        
        let layoutView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.baseBackground
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        let detailLabel: UILabel = {
            let label = UILabel()
            label.text = detail
            label.textColor = UIColor.textPrimary
            label.font = UIFont.pretendard(type: .regular, size: 14.0)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let locationLabel: UILabel = {
            let label = UILabel()
            label.text = location
            label.textColor = UIColor.textPrimary
            label.font = UIFont.pretendard(type: .regular, size: 14.0)
            label.textAlignment = .right
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        if loop == 1 {
            containerView.addSubview(layoutView)
            layoutView.leadingAnchor.constraint(equalTo: floor.leadingAnchor, constant: 0).isActive = true
            layoutView.topAnchor.constraint(equalTo: floor.bottomAnchor, constant: 10).isActive = true
            layoutView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
            layoutView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15).isActive = true
            
            layoutView.addSubview(detailLabel)
            detailLabel.leadingAnchor.constraint(equalTo: layoutView.leadingAnchor, constant: 0).isActive = true
            detailLabel.topAnchor.constraint(equalTo: layoutView.topAnchor, constant: 0).isActive = true
            detailLabel.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor, constant: 0).isActive = true
            
            layoutView.addSubview(locationLabel)
            locationLabel.trailingAnchor.constraint(equalTo: layoutView.trailingAnchor, constant: -25).isActive = true
            locationLabel.topAnchor.constraint(equalTo: detailLabel.topAnchor, constant: 0).isActive = true
            locationLabel.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor, constant: 0).isActive = true
            locationLabel.leadingAnchor.constraint(greaterThanOrEqualTo: detailLabel.trailingAnchor, constant: 0).isActive = true
            
            if isOrient {
                detailLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
                locationLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
            } else {
                detailLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
                locationLabel.widthAnchor.constraint(equalToConstant: 190).isActive = true
            }
        } else {
            let lastView = containerView.subviews.last!
            let lastConst = containerView.constraints.last!
            containerView.removeConstraint(lastConst)
            containerView.addSubview(layoutView)
            
            layoutView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 10).isActive = true
            layoutView.leadingAnchor.constraint(equalTo: lastView.leadingAnchor, constant: 0).isActive = true
            layoutView.trailingAnchor.constraint(equalTo: lastView.trailingAnchor, constant: 0).isActive = true
            layoutView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15).isActive = true
            
            layoutView.addSubview(detailLabel)
            detailLabel.leadingAnchor.constraint(equalTo: layoutView.leadingAnchor, constant: 0).isActive = true
            detailLabel.topAnchor.constraint(equalTo: layoutView.topAnchor, constant: 0).isActive = true
            detailLabel.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor, constant: 0).isActive = true

            layoutView.addSubview(locationLabel)
            locationLabel.trailingAnchor.constraint(equalTo: layoutView.trailingAnchor, constant: -25).isActive = true
            locationLabel.topAnchor.constraint(equalTo: detailLabel.topAnchor, constant: 0).isActive = true
            locationLabel.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor, constant: 0).isActive = true
            locationLabel.leadingAnchor.constraint(greaterThanOrEqualTo: detailLabel.trailingAnchor, constant: 0).isActive = true
            
            if isOrient {
                detailLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
                locationLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
            } else {
                detailLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
                locationLabel.widthAnchor.constraint(equalToConstant: 190).isActive = true
            }
            
        }
    }
}
