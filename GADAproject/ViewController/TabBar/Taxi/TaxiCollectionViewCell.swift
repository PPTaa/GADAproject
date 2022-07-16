//
//  TaxiCollectionViewCell.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import UIKit
import SnapKit

class TaxiCollectionViewCell: UICollectionViewCell {
    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = TaxiCollectionViewCell()
        cell.setTitle(title: name)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    private let taxiLocationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendard(type: .medium, size: 16)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taxiLocationView: UIView = {
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
        taxiLocationLabel.text = title
    }
    
    func setupView() {
        contentView.addSubview(taxiLocationView)
        taxiLocationView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        taxiLocationView.addSubview(taxiLocationLabel)
        taxiLocationLabel.snp.makeConstraints {
            $0.leading.equalTo(taxiLocationView).offset(12)
            $0.trailing.equalTo(taxiLocationView).offset(-12)
            $0.top.equalTo(taxiLocationView).offset(3)
            $0.bottom.equalTo(taxiLocationView).offset(-3)
        }
    }
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                taxiLocationLabel.textColor = .textBtnActive
                taxiLocationView.layer.borderWidth = 1
                taxiLocationView.backgroundColor = .buttonActive
            } else {
                taxiLocationLabel.textColor = .textSecondary
                taxiLocationView.layer.borderWidth = 0
                taxiLocationView.backgroundColor = .clear
                taxiLocationView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func prepareForReuse() {
        isSelected = false
    }
}
