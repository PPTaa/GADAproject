//
//  SceneDelegate.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import UIKit
import SwiftyUserDefaults
import SwiftyJSON
import Alamofire

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
        if let id = Defaults.defaults.string(forKey: BaseConst.SPC_USER_ID), let pw = Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD) {
            
            DataShare.shared().isMainEnter = true
            
            requestLogin(id: id, pwd: pw)
            
            let sb = UIStoryboard(name: "Survey", bundle: nil)
            let randomNum = Int.random(in: 0...1)
//            let randomNum = 1
            var vc = UIViewController()
            if randomNum == 1 {
                vc = sb.instantiateViewController(withIdentifier: "SurveyViewController")
            } else {
                vc = sb.instantiateViewController(withIdentifier: "SurveySubjectiveViewController")
            }
            
            window?.rootViewController = vc
        } else {
            DataShare.shared().isMainEnter = false
            
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
    
    private func requestLogin(id:String, pwd:String) -> Void {
        print("requestLogin+++++++++++ \(id) \(pwd)")
        SLoader.showLoading()
        
        var params:[String:Any] = [
            "cell" : id,
            "password" : pwd
        ]
        
        let path:String = BaseConst.GADA_SERVICE_SERVER_HOST + BaseConst.NET_GADA_LOGIN

        AF.request(path, method: .post, parameters: params, encoding: JSONEncoding.default, headers: BaseConst.headers).responseJSON { response in
            SLoader.hide()
            switch response.result {
            case .success(let data):
                print(data)
                let result = JSON(data)
                if !result.isEmpty {
                    print("result - \(result)")
                    // # 등록 성공 시
                    if result["cell_num"].intValue == 201 {
                        // 가입한 회원 정보가 없음
                    } else if result["cell_num"].intValue == 202 {
                        // 비밀번호 틀림
                    } else {
                        Defaults.defaults.setValue(true, forKey: BaseConst.SPC_USER_LOGIN)
                        Defaults.defaults.setValue(id, forKey: BaseConst.SPC_USER_ID)
                        Defaults.defaults.setValue(pwd, forKey: BaseConst.SPC_USER_PWD)

                        DataShare.shared().profileDao.cell_num = result["cell_num"].stringValue
                        DataShare.shared().profileDao.weak_type = result["category"].stringValue
                        DataShare.shared().profileDao.hc_type = result["tool_type"].stringValue
                        DataShare.shared().profileDao.f_mobil = result["f_mobil"].stringValue
                        DataShare.shared().profileDao.name = result["nickname"].stringValue
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

