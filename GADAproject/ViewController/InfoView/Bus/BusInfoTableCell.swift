//
//  BusInfoTableCell.swift
//  handycab
//
//  Created by leejungchul on 2022/05/03.
//

import Foundation
import UIKit

class BusInfoTableCell: UITableViewCell {
    
    @IBOutlet weak var stationTitle: UILabel!
    @IBOutlet weak var stationNumber: UILabel!
    @IBOutlet weak var stationIcon: UIImageView!
    @IBOutlet weak var upperLine: UIView!
    @IBOutlet weak var lowerLine: UIView!
    
    @IBOutlet weak var busIcon: UIImageView!
    @IBOutlet weak var busIconCenterConst: NSLayoutConstraint!
    
}

