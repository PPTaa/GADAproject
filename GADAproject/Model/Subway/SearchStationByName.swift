//
//  SearchStationByName.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import Foundation

struct SearchStationByName: Codable {
    var subwayList: [StationInfo]?
}
struct StationInfo: Codable {
    var RAIL_OPR_ISTT_CD: String?
    var RAIL_OPR_ISTT_NM: String?
    var LN_CD: String?
    var LN_NM: String?
    var STIN_CD: String?
    var STIN_NM: String?
    var TEL: String?
    var STATION_ID: String?
}
