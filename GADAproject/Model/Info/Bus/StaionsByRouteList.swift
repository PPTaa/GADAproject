//
//  StaionsByRouteList.swift
//  handycab
//
//  Created by leejungchul on 2022/05/03.
//

import Foundation

struct StaionsByRouteList: Codable {
    var msgBody: RouteListMsgBody?
}
struct RouteListMsgBody: Codable {
    var itemList: [RouteListItem]?
}
struct RouteListItem: Codable {
    var busRouteId: String?
    var busRouteNm: String?
    var seq: String?
    var section: String?
    var station: String?
    var arsId: String?
    var stationNm: String?
    var gpsX: String?
    var gpsY: String?
    var posX: String?
    var posY: String?
    var fullSectDist: String?
    var direction: String?
    var stationNo: String?
    var routeType: String?
    var beginTm: String?
    var lastTm: String?
    var trnstnid: String?
    var sectSpd: String?
    var transYn: String?
}
