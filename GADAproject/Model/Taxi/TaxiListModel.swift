//
//  TaxiListModel.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import Foundation

struct TaxiListCall: Codable {
    var division: String = ""// 경기도
    var region: String = "" // 광명시
    var call_name: String = "" // 광명장애인콜
    var phone_number: String = ""// 02-2688-2582
    var name: String = "" // 광명희망카
    var operating_name: String = "" // 광명시사회복지협의회 교통약자이동지원센터
    var idx: Int = 0 // 인덱스
}

struct TaxiLocationListCall {
    var location: [String] = ["서울", "경기", "광역시", "강원"]
}
