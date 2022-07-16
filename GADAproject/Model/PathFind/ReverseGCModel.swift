//
//  ReverseGCModel.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/27.
//

import Foundation

struct ReverseGCModel: Codable {
    
    var results: [ReverseGCResult]
    var status: ReverseGCStatus
}

struct ReverseGCResult: Codable {
    var name: String
    var code: ReverseGCResultCode
    var region: ReverseGCResultRegion
    var land: ReverseGCResultLand
}

struct ReverseGCResultCode: Codable {
    var id: String // 코드 값
    var type: String // 코드 타입 예) L: 법정동, A: 행정동, S: 동일법정동 이름 존재하는 행정동
    var mappingId: String // id와 관련된 매핑코드
}

struct ReverseGCResultRegion: Codable {
    var area0: ReverseGCResultRegionArea // 국가코드 최상위 도메인 두자리
    var area1: ReverseGCResultRegionArea // 행정구역 단위 명칭 1 (시/도)
    var area2: ReverseGCResultRegionArea // 행정구역 단위 명칭 2 (시/군/구)
    var area3: ReverseGCResultRegionArea // 행정구역 단위 명칭 3 (읍/면/동)
    var area4: ReverseGCResultRegionArea // 행정구역 단위 명칭 4 (리)
}

struct ReverseGCResultRegionArea: Codable {
    var name: String // 명칭
    var coords: ReverseGCResultRegionAreaCoords // 좌표
}

struct ReverseGCResultRegionAreaCoords: Codable {
    var center: ReverseGCResultRegionAreaCoordsCenter // 중심좌표
}

struct ReverseGCResultRegionAreaCoordsCenter: Codable {
    var crs: String // 좌표계 코드
    var x: Double // 경도 Lon
    var y: Double // 위도 Lat
}

struct ReverseGCResultLand: Codable {
    var coords: ReverseGCResultRegionAreaCoords // 지적구역과 관계된 좌표
    var name: String? // 도로명 주소일 경우만 사용
    var number1: String // 상세번호 1 (토지 본번호 / 도로명 상세주소)
    var number2: String // 상세번호 2 (토지 부번호 / 도로명 X)
    var type: String // 지적 타입 (1: 일반토지, 2: 산)
}

struct ReverseGCStatus: Codable {
    var code: Int
    var name: String
    var message: String    
}
