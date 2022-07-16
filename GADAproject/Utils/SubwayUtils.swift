//
//  SubwayUtils.swift
//  GADA
//
//  Created by leejungchul on 2022/07/04.
//

import Foundation

class SubwayUtils {
    
    private static var sharedSubwayUtils: SubwayUtils = {
        
        let obj = SubwayUtils(/*parameta*/)
        
        return obj
    }()
    
    private init(/*parameta*/) {
    }
    
    class func shared() -> SubwayUtils {
        return sharedSubwayUtils
    }
    
    public func laneCdChange(laneCd: String) -> String {
        var InCd = ""
        switch laneCd {
        case "I1":
            InCd = "21"
        case "I2":
            InCd = "22"
        case "A1":
            InCd = "101"
        case "M1":
            InCd = "102"
        case "K4":
            InCd = "104"
        case "E1":
            InCd = "107"
        case "K2":
            InCd = "108"
        case "D1":
            InCd = "109"
        case "U1":
            InCd = "110"
        case "K5":
            InCd = "112"
        case "UI":
            InCd = "113"
        case "WS":
            InCd = "114"
        case "G1":
            InCd = "115"
        case "K1":
            InCd = "116"
        case "신림선":
            InCd = "117"
        case "21":
            InCd = "I1"
        case "22":
            InCd = "I2"
        case "101":
            InCd = "A1"
        case "102":
            InCd = "M1"
        case "104":
            InCd = "K4"
        case "107":
            InCd = "E1"
        case "108":
            InCd = "K2"
        case "109":
            InCd = "D1"
        case "110":
            InCd = "U1"
        case "112":
            InCd = "K5"
        case "113":
            InCd = "UI"
        case "114":
            InCd = "WS"
        case "115":
            InCd = "G1"
        case "116":
            InCd = "K1"
        case "117":
            InCd = "신림선"
        default:
            InCd = laneCd
        }
        return InCd
    }
    
    public func changeNameToCode(lineName: String) -> String {
        var lnCd = ""
        switch lineName {
        case "01호선":
            lnCd = "1"
        case "02호선":
            lnCd = "2"
        case "03호선":
            lnCd = "3"
        case "04호선":
            lnCd = "4"
        case "05호선":
            lnCd = "5"
        case "06호선":
            lnCd = "6"
        case "07호선":
            lnCd = "7"
        case "08호선":
            lnCd = "8"
        case "09호선":
            lnCd = "9"
        case "인천선":
            lnCd = "I1"
        case "인천2호선":
            lnCd = "I2"
        case "공항철도":
            lnCd = "A1"
        case "경의선":
            lnCd = "K4"
        case "경춘선":
            lnCd = "K2"
        case "신분당선":
            lnCd = "D1"
        case "경강선":
            lnCd = "K5"
        case "수인분당선":
            lnCd = "K1"
        case "의정부경전철":
            lnCd = "U1"
        default:
            lnCd = "1"
        }
        return lnCd
    }
    
    public func getRailOprIsttCd(lnCd: String, stinCd: String) -> String {
        
        var railOprIsttCd = ""
        switch lnCd {
        case "1":
            railOprIsttCd = "KR"
            if Int(stinCd) ?? 0 <= 133 && Int(stinCd) ?? 0 >= 124 {
                railOprIsttCd = "S1"
            }
        case "2":
            railOprIsttCd = "S1"
        case "3":
            railOprIsttCd = "S1"
            if Int(stinCd) ?? 0 <= 318 && Int(stinCd) ?? 0 >= 309 {
                railOprIsttCd = "KR"
            }
        case "4":
            railOprIsttCd = "S1"
            if Int(stinCd) ?? 0 <= 456 && Int(stinCd) ?? 0 >= 435 {
                railOprIsttCd = "KR"
            }
        case "5", "6", "7", "8":
            railOprIsttCd = "S5"
        case "9":
            railOprIsttCd = "S9"
        case "I1", "I2":
            railOprIsttCd = "IC"
        case "A1":
            railOprIsttCd = "AR"
        case "K4","K2","K5","K1":
            railOprIsttCd = "KR"
        case "D1":
            railOprIsttCd = "DX"
        default:
            railOprIsttCd = "S1"
        }
        return railOprIsttCd
    }
    // 호선별 예외처리
    public func stinCdChange(FR_CODE: String, lnCd: String) -> String {
        
        var stinCd = "\(FR_CODE)"
        var list = Array(FR_CODE)
        var firstCd = ""
        var cdString = ""
        var cdInt = 0
        
        
        for (i,v) in list.enumerated() {
            print(i, v)
            if i == 0 {
                print(v)
                firstCd = String(v)
            } else {
                cdString += String(v)
                cdInt = Int(cdString) ?? 0
            }
        }
        // 경춘선
        if lnCd == "K2" {
            if FR_CODE == "P116" {
                stinCd = "119"
            } else if cdInt >= 117 && cdInt <= 121 {
                firstCd = "K"
                stinCd = "\(firstCd)\(cdInt)"
            }
        }
        
       
        return stinCd
    }
}
