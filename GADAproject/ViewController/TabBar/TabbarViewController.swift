//
//  TabbarViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/08.
//

import UIKit
import Alamofire

class TabbarViewController: UITabBarController {

    var version: [String]? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String else {return nil}

        let versionAndBuild: [String] = [version, build]
        return versionAndBuild
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataShare.shared().isMainEnter = true
        
        subwayLaneSetting()
        // Do any additional setup after loading the view.
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
        print(tabBar)
    }
    
    private func subwayLaneSetting() {
        
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_STATION_LANE_SEARCH
        AF.request(url, method: .post, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                do {
                    print(data)
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(SearchAllSubwayLane.self, from: jsonData)
                    print("SearchAllSubwayLane result = \(getInstanceData.result) ")
                    DataShare.shared().subwayLaneList = getInstanceData.result
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("error: \(error)")
                break
            }
        }
    }
}

