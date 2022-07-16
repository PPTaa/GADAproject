//
//  SplashViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/28.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON

class SplashViewController: UIViewController {


    private var confirmDialog:ConfirmPopupView!
    private var alertDialog:AlertPopupView!
    
    var version: [String]? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String else {return nil}

        let versionAndBuild: [String] = [version, build]
        return versionAndBuild
    }
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        versionCheck(version: version?[0] ?? "")
        
        subwayLaneSetting()
    }
    
    
    private func moveLogin() {
        let storyBoard:UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let vc = storyBoard.instantiateViewController(withIdentifier: "IntroNavigationController") as! NavigationController
        
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
//        guard let navigationVC = self.navigationController else { return }
//        navigationVC.popViewController(animated: false)
//        navigationVC.pushViewController(vc, animated: false)
    }
    
    private func moveHome() {
        let sb = UIStoryboard(name: "tabbar", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "tabbarViewController") as! TabbarViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
//        guard let window = UIApplication.shared.keyWindow else {
//            return
//        }
//        window.rootViewController = vc
        present(vc, animated: true, completion: nil)
    }
    
    // # 로그인
    private func requestLogin(id:String, pwd:String) -> Void {
                
//        SLoader.showLoading()
        print(#function, id, pwd)
        
        let params:[String:Any] = [
            "cell_num" : id,
            "passwd" : pwd
        ]
        let header = BaseConst.headers
                
        let path:String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_MEMBER_LOGIN
        
        AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString, headers: header).responseString { response in

            switch response.result {
            case .success(let data):
                print(data)

                // # 등록 성공 시
                if data == "200" {
                    DispatchQueue.main.async {
                        [self] in
                        requestProfile(cellNum: id, passwd: pwd)
                    }
                } else {
                    DispatchQueue.main.async {
                        [self] in
                        moveLogin()
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func requestProfile(cellNum: String, passwd: String) -> Void {
                
        SLoader.showLoading()
        let params:[String:Any] = [
            "cell_num" : cellNum,
            "passwd" : passwd
        ]
        
        var header = BaseConst.headers
        
        let path:String = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_MEMBER_INFO
        
        AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString, headers: header).response { response in
            let result = response.result
            print("response : \(response)")
            print("response.result : \(result)")
            switch response.result {
            case .success(let data):
                let result = JSON(data)
                print("JSON(data) : \(JSON(data))")
                // #
                let arr = result.arrayValue
                if arr.count > 0 {
                    
                    let cellNum = arr[0]["cell_num"].stringValue
                    let birthday = arr[0]["birthymd"].stringValue
                    let use = arr[0]["use_yn"].stringValue
                    let weak_type = arr[0]["weak_type"].stringValue
                    let hc_type = arr[0]["hc_type"].stringValue
                    let er_key = arr[0]["er_key"].stringValue
                    let b_type = arr[0]["b_type"].stringValue
                    let g_name = arr[0]["g_name"].stringValue
                    let gcell_num = arr[0]["gcell_num"].stringValue
                    let f_mobil = arr[0]["f_mobil"].stringValue
                    let name = arr[0]["nickname"].stringValue
                    let profileImage = arr[0]["profileImage"].stringValue
                    
                    // # 탈퇴 회원 체크
                    if "N" == use {
                        
                        DispatchQueue.main.async {
                            [self] in
                            moveLogin()
                        }
                        return
                    }
                    
                    
                    Defaults.defaults.set(name, forKey: BaseConst.SPC_USER_NAME)
                    Defaults.defaults.set(cellNum, forKey: BaseConst.SPC_USER_PHONE)
                    Defaults.defaults.set(birthday, forKey: BaseConst.SPC_USER_BIRTHDAY)
                    Defaults.defaults.set(profileImage, forKey: BaseConst.SPC_USER_IMAGE)
                    
                    
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
                    DataShare.shared().profileDao.profileImage = profileImage
                    
//                    self.moveRealmToDB()
                    self.moveHome()
                    
                }else {
                    
                    DispatchQueue.main.async {
                        [self] in
                        
                        if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
                        alertDialog = (UIStoryboard.init(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
                        alertDialog.modalTransitionStyle = .crossDissolve
                        alertDialog.modalPresentationStyle = .overCurrentContext
                        
                        alertDialog.descString = "text_login_12".localized()
                        alertDialog.confirmString = "confirm".localized()
                        alertDialog.confirmClick = { () -> () in  }
                        present(alertDialog, animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
//                    print("SearchAllSubwayLane result = \(getInstanceData) ")
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
    
    private func versionCheck(version: String) {
        let url = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_APP_VERSION
        AF.request(url, method: .post, encoding: URLEncoding.queryString).responseString(completionHandler: { response in
            switch response.result {
            case .success(let data) :
                print("latest Version : ", data)
                print("current Version : ", version)
                print("latest Version == current Version :", data == version)
                if data != version {
                    DispatchQueue.main.async {
                        [self] in
                        
                        if alertDialog != nil { alertDialog.dismiss(animated: false, completion: nil) }
                        alertDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "AlertPopupView") as! AlertPopupView)
                        alertDialog.modalTransitionStyle = .crossDissolve
                        alertDialog.modalPresentationStyle = .overCurrentContext
                        
                        alertDialog.descString = "version_error".localized()
                        alertDialog.confirmString = "confirm".localized()
                        alertDialog.confirmClick = { () -> () in
                            UsefulUtils.openAppStore(appId: "1565120749")
                        }
                        present(alertDialog, animated: true, completion: nil)
                    }
                } else {
                    if Defaults.defaults.bool(forKey: BaseConst.SPC_USER_LOGIN) {
                        
                        if let id = Defaults.defaults.string(forKey: BaseConst.SPC_USER_ID) {
                         
                            if let pwd = Defaults.defaults.string(forKey: BaseConst.SPC_USER_PWD) {
//                                self.requestLogin(id: id, pwd: pwd)
                                self.moveLogin()
                            } else {
                                self.moveLogin()
                            }
                        } else {
                            self.moveLogin()
                        }
                    }
                    else {
                        self.moveLogin()
                    }
                }
            case .failure(let error):
                print("error: \(error)")
                break
            }
        })
    }
}
