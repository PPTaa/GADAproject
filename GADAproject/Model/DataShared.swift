//
//  DataShared.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/04.
//

import Foundation
import SwiftyUserDefaults

class DataShare {
    
    private static var dataShare: DataShare = {
        
        let obj = DataShare(/*parameta*/)
        
        return obj
    }()
    
    class func shared() -> DataShare {
        return dataShare
    }
    
    public var joindao: JoinDao! = JoinDao()
    public var favoriteDataList = [Favorite]()
    public var subwayLaneList: Array<SubwayLane>?
    public var profileDao: Profile! = Profile()
    public var favoriteDao: [Favorite] = [Favorite]()
    public var favoriteName: [String] = [String]()
}
