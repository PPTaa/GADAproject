//
//  SearchPathModel.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/30.
//

import Foundation
import TMapSDK


public class SearchPathModel: NSObject {
    
    var closure: (() -> Void)?
    
    public var name:String = ""
    public var address:String = ""
    public var lat:String = ""
    public var lon:String = ""
    public var isrecent:Bool = false
    
    public var recent:Array<SearchPathModel> = Array()
    
    
    // #
    public var pathType:Int = 0
    
    public var busStationCount:Int = 0
    public var busTransitCount:Int = 0
    public var firstStartStation:String = ""
    public var lastEndStation:String = ""
    public var payment:Int = 0
    public var subwayStationCount:Int = 0
    public var subwayTransitCount:Int = 0
    public var totalDistance:Int = 0
    public var totalStationCount:Int = 0
    public var mapObj:String = ""
    public var totalTime:Int = 0
    public var totalWalk:Int = 0
    public var totalWalkTime:Int = 0
    public var trafficDistance:Int = 0
    
    
    public var subPath:Array<SearchPathModel> = Array()
    public var trafficType:Int = 0
    public var distance:Int = 0
    public var sectionTime:[Int] = [0]
    public var sectionTrafficType:[Int] = [0]
    public var stationCount:Int = 0
    public var startName:String = ""
    public var startX:Int = 0
    public var startY:Int = 0
    public var endName:String = ""
    public var endX:Int = 0
    public var endY:Int = 0
    public var way:String = ""
    public var wayCode:Int = 0
    public var door:String = ""
    public var startID:Int = 0
    public var endID:Int = 0
    public var startExitNo:String = ""
    public var startExitX:Double = 0
    public var startExitY:Double = 0
    public var endExitNo:String = ""
    public var endExitX:Double = 0
    public var endExitY:Double = 0
    public var exitLatLon = [(startExitLon: Double, startExitLat: Double, endExitLon: Double, endExitLat: Double, busNo: String)]()
    public var seName = [(String,String,String,String,String,String)]()
    public var widthLists = [CGFloat]()
    public var subwayCodeLists:[Int] = [0]
    public var detailPathData = [SearchPathData]()
    
    
    public var lane:Array<SearchPathModel> = Array()
    public var type:Int = 0
    public var busNo:String = ""
    public var busID:Int = 0
    public var laneName:String = ""
    public var subwayCode:Int = 0
    public var subwayCityCode:Int = 0
    
    
    public var stations:Array<SearchPathModel> = Array()
    public var index:Int = 0
    public var stationID:Int = 0
    public var stationName:String = ""
    
    
    public var coordinates:Array<CLLocationCoordinate2D> = Array()
}
