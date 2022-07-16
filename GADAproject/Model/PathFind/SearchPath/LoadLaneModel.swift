//
//  LoadLaneModel.swift
//  handycab
//
//  Created by leejungchul on 2022/06/14.
//

import Foundation
import CoreLocation

struct requestLoadLaneResult: Codable {
    var result: laneSectionResult?
}
struct laneSectionResult: Codable {
    var lane: [laneData]
    var boundary: boundaryData
}
struct laneData: Codable {
    var trafficClass: Int
    var type: Int
    var section: [sectionData]
    
    enum CodingKeys : String, CodingKey  {
        case trafficClass = "class"
        case type
        case section
    }
}
struct sectionData: Codable { 
    var graphPos: [graphPosData]
}
struct graphPosData: Codable {
    var x: Double
    var y: Double
}

struct boundaryData: Codable {
    var left: Double
    var top: Double
    var right: Double
    var bottom: Double
}
