//
//  StoreData.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/20.
//

import Foundation

struct StoreData {
    var likeCount: Int
    var storeTitle: String
    var storeCategory: String
    var storeDescription: String
    var storeTag: String
    var storeImageRoute: String?
    var isLike: Bool = false

}

struct StoreDetailData {
    var location: String
    var phone: String
    var time: String
    var exit: String
    var info: String
    var parking: String
    var convenience: String
}
