//
//  SearchLocationTableViewCell.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/30.
//

import Foundation

class NothingCell: UITableViewCell {
    
}

class SearchCellHeader: UITableViewCell {

    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerMoreBtn: UIButton!

}

class SearchCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var bizName: UILabel!
    
}

class RecentSearchCell: UITableViewCell {
        
    @IBOutlet weak var recentSearchName: UILabel!
    @IBOutlet weak var recentSearchDate: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
}

class NoneCell: UITableViewCell {
    @IBOutlet var basicText: UILabel!
}

//class RecentSearchPathCell: UITableViewCell {
//
//    @IBOutlet weak var startAddress: UILabel!
//    @IBOutlet weak var endAddress: UILabel!
//
//}
