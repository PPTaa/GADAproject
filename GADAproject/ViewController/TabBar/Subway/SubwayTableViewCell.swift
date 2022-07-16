//
//  SubwayTableViewCell.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit
import SnapKit

class SubwayTableViewCell: UITableViewCell {
    let stationIcon: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(type: .medium, size: 18)
        label.textColor = .textPrimary
        return label
    }()
    
    let phoneCallBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "call_btn"), for: .normal)
        return button
    }()
    
    let subwayFavoriteBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like_24"), for: .normal)
        button.setImage(UIImage(named: "like_filled_24"), for: .selected)
        return button
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code'
        layout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layout() {
        UsefulUtils.roundingCorner(view: phoneCallBtn)
        [stationIcon, titleLabel, phoneCallBtn, subwayFavoriteBtn].forEach {
            contentView.addSubview($0)
        }
        
        stationIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(titleLabel)
            
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(stationIcon.snp.trailing).offset(6)
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(24)
        }
        subwayFavoriteBtn.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-16)
        }
        phoneCallBtn.snp.makeConstraints {
            $0.width.equalTo(49)
            $0.height.equalTo(24)
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(subwayFavoriteBtn.snp.leading).offset(-12)
        }
        
    }

}
