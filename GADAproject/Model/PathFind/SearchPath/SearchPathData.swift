//
//  SearchPathData.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/30.
//

import Foundation

public struct SearchPathData {
    var isSelected: Bool = false
    var laneCd: String
    var title: String
    var detail: String
    var time: String
    var move: String
    var stationList: [String]
    var stationCodeList: [String]?
    var busLocalBlID: String? // 버스api 검색 가능한 ID
    var startExitNo: String?
    var endExitNo: String?
    var stinCd: String?
    var routeEndData: [String]?
    var distance: String
}
