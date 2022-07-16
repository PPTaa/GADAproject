//
//  BusRouteInfo.swift
//  handycab
//
//  Created by leejungchul on 2022/05/03.
//

import Foundation

struct BusRouteInfo: Codable {
    var msgBody: RouteInfoMsgBody?
}
struct RouteInfoMsgBody: Codable {
    var itemList: [RouteInfoItem]?
}
struct RouteInfoItem: Codable {
    var busRouteId: String?
    var busRouteNm: String?
    var length: String?
    var routeType: String?
    var stStationNm: String?
    var edStationNm: String?
    var term: String?
    var lastBusYn: String?
    var lastBusTm: String?
    var firstBusTm: String?
    var lastLowTm: String?
    var firstLowTm: String?
    var corpNm: String?
}
