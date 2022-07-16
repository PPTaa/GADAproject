//
//  RecentSearch.swift
//  HANDYCAB_RE
//
//  Created by leejungchul on 2021/05/21.
//

import Foundation
import RealmSwift

class RecentSearch: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var time: String = ""

}
