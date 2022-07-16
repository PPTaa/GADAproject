//
//  SubwayLineModel.swift
//  HANDYCAB_RE
//
//  Created by leejungchul on 2021/06/15.
//

import Foundation

public class SubwayLineModel: NSObject {
    var routCd: String = ""
    var stinCd: String = ""
    var stinNm: String = ""
    var lnCd: String = ""
    var railOprIsttCd: String = ""
    var stinConsOrdr: String = ""
    var routNm: String = ""
    var mreaWideCd: String = ""
    var nextStinCd: String = ""
    var prevStinCd: String = ""
    var stationPhone: String = ""
}

struct SubwayModel: Codable {
    var body: Array<SubwayModelBody>?
}

struct SubwayModelBody: Codable {
    var lnCd: String
    var mreaWideCd: String
    var railOprIsttCd: String
    var routCd: String
    var routNm: String
    var stinCd: String
    var stinConsOrdr: Int
    var stinNm: String
    
    init(lnCd: String, mreaWideCd: String, railOprIsttCd: String, routCd: String, routNm: String, stinCd: String, stinConsOrdr: Int, stinNm: String) {
        // This initializer is not called if Decoded from JSON!
        self.lnCd = lnCd
        self.mreaWideCd = mreaWideCd
        self.routCd = routCd
        self.stinCd = stinCd
        self.stinConsOrdr = stinConsOrdr
        self.stinNm = stinNm
        self.railOprIsttCd = railOprIsttCd
        self.routNm = routNm
    }
}

struct SearchAllSubwayLane: Codable {
    var result: Array<SubwayLane>?
}
struct SubwayLane: Codable {
    var LN_CD: String?
    var LN_NM: String?
}
