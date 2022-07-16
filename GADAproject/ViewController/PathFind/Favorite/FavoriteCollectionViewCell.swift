//
//  FavoriteCollectionViewCell.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import UIKit
import SnapKit

class FavoriteCollectionViewCell: UICollectionViewCell {
    
    let iconImage = UIImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSans(type: .regular, size: 14)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        setupItem()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupItem()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.height / 2
    }
    
    func setupLayout() {
        [iconImage, titleLabel].forEach {
            contentView.addSubview($0)
        }
        iconImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
            $0.leading.equalToSuperview().offset(10)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImage.snp.trailing).offset(4)
            $0.centerY.equalTo(iconImage)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
    
    func setupItem() {
//        contentView.backgroundColor = .systemBackground
        self.layer.backgroundColor = UIColor.baseBackground?.cgColor
    }
    
    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = FavoriteCollectionViewCell()
        cell.configure(name: name, imageName: "favoriteCell_default")
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .required)
    }
    
    func configure(name: String?, imageName: String) {
        titleLabel.text = name
        iconImage.image = UIImage(named: imageName)
    }
}


class FavoriteMoreCollectionViewCell: UICollectionViewCell {
    
    let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "favoriteCell_more")!
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        setupItem()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupItem()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.height / 2
    }
    
    func setupLayout() {
        [iconImage].forEach {
            contentView.addSubview($0)
        }
        iconImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
        }
    }
    
    func setupItem() {
        self.layer.backgroundColor = UIColor.baseBackground?.cgColor
    }
}



final class FavoriteCell: UICollectionViewCell {
    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = FavoriteCell()
        cell.configure(name: name, imageName: "icNewLocation", imageHeight: 20)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    func configure(name: String?, imageName: String, imageHeight: CGFloat) {
        testLabel.text = name
        iconImageView.image = UIImage(named: imageName)
    }
    
    private let testLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.heightAnchor.constraint(equalToConstant: 20).isActive = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func setupView() {
        contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
        contentView.addSubview(testLabel)
        testLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        testLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4).isActive = true
        testLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
}

final class MoreCell: UICollectionViewCell {
    
    private let iconImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "icMoreRight")
        image.contentMode = .scaleAspectFit
        image.heightAnchor.constraint(equalToConstant: 20).isActive = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func setupView() {
        contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    }
}
