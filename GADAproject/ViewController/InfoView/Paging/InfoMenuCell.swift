//
//  BusInfoMenuCell.swift
//  handycab
//
//  Created by leejungchul on 2022/04/13.
//

import Foundation
import UIKit
import PagingKit

class InfoMenuCell: PagingMenuViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    override public var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = .textPrimary
            } else {
                titleLabel.textColor = .textSecondary
            }
        }
    }
}
