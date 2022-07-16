//
//  TaxiListTableCell.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import UIKit

class TaxiListTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel1: UILabel!
    @IBOutlet weak var detailLine: UIView!
    @IBOutlet weak var detailLabel2: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    
    
    @IBOutlet weak var detailLineLeftConst: NSLayoutConstraint!
    @IBOutlet weak var detailLineRightConst: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
