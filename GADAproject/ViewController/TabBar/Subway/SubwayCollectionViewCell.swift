//
//  SubwayCollectionViewCell.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit
import SnapKit

class SubwayCollectionViewCell: UICollectionViewCell {
    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = SubwayCollectionViewCell()
        cell.setTitle(title: name)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    private let subwayLaneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(type: .medium, size: 16)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subwayLaneView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.baseBackground?.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setTitle(title: String?) {
        subwayLaneLabel.text = title
    }
    
    func setupView() {
        contentView.addSubview(subwayLaneView)
        subwayLaneView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        subwayLaneView.addSubview(subwayLaneLabel)
        subwayLaneLabel.snp.makeConstraints {
            $0.leading.equalTo(subwayLaneView).offset(12)
            $0.trailing.equalTo(subwayLaneView).offset(-12)
            $0.top.equalTo(subwayLaneView).offset(3)
            $0.bottom.equalTo(subwayLaneView).offset(-3)
        }
    }
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                subwayLaneLabel.textColor = .textBtnActive
                subwayLaneView.layer.borderWidth = 1
                subwayLaneView.backgroundColor = .buttonActive
            } else {
                subwayLaneLabel.textColor = .textSecondary
                subwayLaneView.layer.borderWidth = 0
                subwayLaneView.backgroundColor = .clear
                subwayLaneView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func prepareForReuse() {
        isSelected = false
    }
}
