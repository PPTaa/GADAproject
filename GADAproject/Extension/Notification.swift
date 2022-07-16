//
//  Notification.swift
//  GADA
//
//  Created by leejungchul on 2021/05/18.
//

import Foundation

extension Notification.Name {
    //검색후 결과 전송
    static let inputSearchValue = Notification.Name("inputSearchValue")
    static let returnMapObj = Notification.Name("returnMapObj")
    static let recieveLoactionData = Notification.Name("recieveLoactionData")
    static let receiveSubwayInfo = Notification.Name("receiveSubwayInfo")
    static let profileImageModify = Notification.Name("profileImageModify")
    static let receiveSubwayConvenientInfo = Notification.Name("receiveSubwayConvenientInfo")
    static let reviewInfo = Notification.Name("reviewInfo")
    static let receiveStationReview = Notification.Name("receiveStationReview")
    static let receiveTransferInfo = Notification.Name("receiveTransferInfo")
    static let apiEnd = Notification.Name("apiEnd")
    static let recieveStartLoactionData = Notification.Name("recieveStartLoactionData")
    static let recieveSearchData = Notification.Name("recieveSearchData")
    static let busRouteInfoData = Notification.Name("busRouteInfoData")
    
    static let joinNoti = Notification.Name("joinNoti")
    
    static let subwaySearchByName = Notification.Name("subwaySearchByName")

}
