//
//  RecentSearchPath.swift
//  HANDYCAB_RE
//
//  Created by leejungchul on 2021/05/21.
//

import Foundation
import RealmSwift

class RecentSearchPath: Object {
    
    @objc dynamic var startAddress: String = ""
    @objc dynamic var startLat: String = ""
    @objc dynamic var startLon: String = ""
    
    @objc dynamic var endAddress: String = ""
    @objc dynamic var endLat: String = ""
    @objc dynamic var endLon: String = ""
}
