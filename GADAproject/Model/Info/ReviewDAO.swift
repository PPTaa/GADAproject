//
//  ReviewDAO.swift
//  handycab
//
//  Created by leejungchul on 2021/09/01.
//

import Foundation

public class ReviewDAO: NSObject {
    
    var closure: (() -> Void)?
    
    public var idx: String = ""
    public var writer:String = ""
    public var station:String = ""
    public var attendantStar:String = ""
    public var convenienceStar:String = ""
    
    public var content:String = ""
    public var writeimage:String = ""
    public var writeDate:String = ""
    public var updateDate:String = ""
    public var stationLane: String = ""
    public var name: String = ""
}
