//
//  SceneDelegate.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import UIKit
import SwiftyUserDefaults
import SwiftyJSON

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        for fontFamily in UIFont.familyNames {
//            for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
//                print(fontName)
//            }
//        }
        guard let _ = (scene as? UIWindowScene) else { return }
        // add these lines
        
        // if user is logged in before
        if Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD) != nil {
            // instantiate the main tab bar controller and set it as root view controller
            // using the storyboard identifier we set earlier
            requestProfile()
            let sb = UIStoryboard(name: "TabBar", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TabbarViewController")
            window?.rootViewController = vc
        } else {
            // if user isn't logged in
            // instantiate the navigation controller and set it as root view controller
            // using the storyboard identifier we set earlier
            let storyBoard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "IntroNavigationController")
            window?.rootViewController = vc
        }
    }
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }

        window.rootViewController = vc

        // add animation
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [.transitionCrossDissolve],
                          animations: nil,
                          completion: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func requestProfile() -> Void {
        print("requestProfile+++++++++++")
        
        SLoader.showLoading()
        
        let params:[String:Any] = [
            "cell_num" : Defaults.defaults.string(forKey: BaseConst.SPC_USER_ID),
            "passwd" : Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD)
        ]
        
        
        let path:String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_MEMBER_INFO
        
        CommonRequest.shared.requestJSON(path, params: params as! [String : String]) {
            
            (_ result: JSON) in
            
            SLoader.hide()
            
            if !result.isEmpty {
                
//                console.i(result)
                
                // # 예외 처리
                if "0" == result["code"].stringValue {
                    return
                }
                
                
                // #
                let arr = result.arrayValue
                print("arr ---- \(arr)")
                
                if arr.count > 0 {
                    
                    let cellNum = arr[0]["cell_num"].stringValue
                    let birthday = arr[0]["birthymd"].stringValue
                    let use = arr[0]["use_yn"].stringValue
                    
                    let weak_type = arr[0]["er_key"].stringValue
                    let hc_type = arr[0]["hc_type"].stringValue
                    
                    let er_key = arr[0]["er_key"].stringValue
                    let b_type = arr[0]["b_type"].stringValue
                    let g_name = arr[0]["g_name"].stringValue
                    let gcell_num = arr[0]["gcell_num"].stringValue
                    
                    let f_mobil = arr[0]["f_mobil"].stringValue
                    
                    let name = arr[0]["nickname"].stringValue
                  
                    Defaults.defaults.set(name, forKey: BaseConst.SPC_USER_NAME)
                    Defaults.defaults.set(cellNum, forKey: BaseConst.SPC_USER_PHONE)
                    Defaults.defaults.set(birthday, forKey: BaseConst.SPC_USER_BIRTHDAY)
                    
                    DataShare.shared().profileDao.cell_num = cellNum
                    DataShare.shared().profileDao.passwd = arr[0]["passwd"].stringValue
                    DataShare.shared().profileDao.birthymd = birthday
                    DataShare.shared().profileDao.weak_type = weak_type
                    DataShare.shared().profileDao.hc_type = hc_type
                    DataShare.shared().profileDao.er_key = er_key
                    DataShare.shared().profileDao.b_type = b_type
                    DataShare.shared().profileDao.g_name = g_name
                    DataShare.shared().profileDao.gcell_num = gcell_num
                    DataShare.shared().profileDao.use_yn = use
                    DataShare.shared().profileDao.f_mobil = f_mobil
                    DataShare.shared().profileDao.name = name
                    
                }
            }
        }
    }
}

