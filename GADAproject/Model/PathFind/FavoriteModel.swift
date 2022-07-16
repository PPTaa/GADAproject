//
//  FavoriteMode.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import Foundation

struct Favorite: Codable {
    
    var nickName: String
    var customName: String
    var name: String?
    var address: String?
    var lat: Double
    var lon: Double
    var idx: Int
}
