//
//  BusLocationById.swift
//  handycab
//
//  Created by leejungchul on 2022/05/13.
//

import Foundation

struct BusLocationById: Codable {
    var msgBody: BusLocationItemList?
}

struct BusLocationItemList: Codable {
    var itemList: [BusLocationItem]?
}

struct BusLocationItem: Codable {
    var busType: String? // 차량유형 (0:일반, 1:저상)
    var congetion: String? // 차량내부혼잡도 (0: 없음, 3: 여유, 4: 보통, 5: 혼잡, 6: 매우혼잡)
    var dataTm: String? // 제공시간
    var fullSectDist: String? // 정류소간 거리
    var gpsX: String? // 맵매칭X좌표 (WGS84)
    var gpsY: String? // 맵매칭Y좌표 (WGS84)
    var isFullFlag: String? // 만차여부
    var islastyn: String? // 막차여부
    var isrunyn: String? // 해당차량 운행여부
    var lastStTm: String? // 종점도착소요시간
    var lastStnId: String? // 최종정류장 ID
    var nextStId: String? // 다음정류소아이디
    var nextStTm: String? // 다음정류소도착소요시간
    var plainNo: String? // 차량번호
//    var posX: String? // 맵매칭X좌표 (GRS80)
//    var posY: String? // 맵매칭Y좌표 (GRS80)
    var rtDist: String? // 노선옵셋거리
    var sectDist: String? // 구간옵셋거리
    var sectOrd: String? // 구간순번
    var sectionId: String? // 구간ID
    var stopFlag: String? // 정류소도착여부(1:도착, 0:운행중)
    var trnstnid: String? // 회차지 정류소ID
    var vehId: String? // 버스ID
}
