import UIKit
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults


/**
 * 공통 HTTP 요청
 */
open class CommonRequest: NSObject {

    /*
    API_MSG_0001    시스템 에러
    API_MSG_0002    [필수] XXX(에)가 없습니다.
    API_MSG_0003    해당 XXX 정보가 없습니다.
    API_MSG_0004    해당 XXX 정보가 맞지 않습니다.
    API_MSG_0005    XXX 형식이 올바르지 않습니다.
    API_MSG_0006    XXX 중복 데이타가 있습니다.
    API_MSG_0007    [필수] {0}(이)가 {1}건 이상 있어야 합니다.
    */
    public static let NET_MSG_0000:String = "NET_MSG_0000"
    public static let API_MSG_0000:String = "API_MSG_0000"
    public static let API_MSG_0001:String = "API_MSG_0001"
    public static let API_MSG_0002:String = "API_MSG_0002"
    public static let API_MSG_0003:String = "API_MSG_0003"
    public static let API_MSG_0004:String = "API_MSG_0004"
    public static let API_MSG_0005:String = "API_MSG_0005"
    public static let API_MSG_0006:String = "API_MSG_0006"
    public static let API_MSG_0007:String = "API_MSG_0007"
    
    enum NetworkError: Error {
        case notConnected
        case noResponse
    }
    
    static let shared = CommonRequest()
    
    
    public func getServer() -> String {
        // DEV_SERVER_HOST
        #if DEBUG
        return BaseConst.DEV_SERVER_HOST
        #else
        return BaseConst.SERVICE_SERVER_HOST
        #endif
    }
    /*
    public func getParams() -> [String:Any] {
        
        var params:[String:Any] = ["os":BaseConst.APP_OS_CODE]
        params["package"] = "handycab.smartmobilityinc.kr"
        params["osversion"] = CommonUtils.getOSVersion()// UIDevice.current.systemVersion
        params["appversion"] = CommonUtils.getVersion()
        params["token"] = Defaults.string(forKey: BaseConst.SPC_PUSH_TOKEN)
        params["service"] = BaseConst.APP_SERVICE_CODE
        // params["auth"] = BaseConst.APP_AUTH
        
        return params
    }
    */
    
    public func request(_ path:String, params:[String : Any], completion: @escaping (_ result: JSON) -> Void) {

        var token:String = ""
        if let t = Defaults.defaults.string(forKey: BaseConst.SPC_USER_TOKEN) {
            token = t
        }
        
        let headers:HTTPHeaders = ["Content-Type": "application/json",
                                   "Accept-Charset": "charset=UTF-8",
                                   "Authorization": "Bearer " + token]
        
        print(path, params)
        
        AF.request(path, method: .post, parameters: params).response { response in
                    
            #if DEBUG
            debugPrint(response)
            #endif
            
            switch response.result {
            case .success(let data):
                
                if String(describing: data).contains("error") {

                    var message = JSON(data)["message"].stringValue
                    if "" == message {
                        message = "service_error".localized()
                    }
                    completion(JSON(["return":false, "code":"0", "message":message]))
                    break
                }
                
                if let d = NSString(data: data!, encoding:String.Encoding.utf8.rawValue) {
                    completion(JSON(["return":true, "code":d]))
                }else {
                    completion(JSON(["return":false, "code":"0"]))
                }
                break
            case .failure(let error):
                
                #if DEBUG
                print(error)
                #endif
                completion(JSON(["return":false, "code":"0", "message":"service_error".localized()]))
            }
        }
    }
    
    public func requestJSON(_ path:String, params:[String : Any], completion: @escaping (_ result: JSON) -> Void) {
                
        var token:String = ""
        if let t = Defaults.defaults.string(forKey: BaseConst.SPC_USER_TOKEN) {
            token = t
        }
        
        let headers:HTTPHeaders = ["Content-Type": "application/json",
                                   "Accept-Charset": "charset=UTF-8",
                                   "Authorization": "Bearer " + token]
        
        print(path, params)
        
        AF.request(path, method: .post, parameters: params).response { response in
                    
            #if DEBUG
            debugPrint(response)
            #endif
            
            switch response.result {
            case .success(let data):
                
                if String(describing: data).contains("error") {

                    var message = JSON(data)["message"].stringValue
                    if "" == message {
                        message = "service_error".localized()
                    }
                    completion(JSON(["return":false, "code":"0", "message":message]))
                    break
                }
                
                if let d = NSString(data: data!, encoding:String.Encoding.utf8.rawValue) {
                    if "[]" == d {
                        completion(JSON( ["code":"0"] ))
                        return
                    }
                    completion(JSON(data))
                }else {
                    completion(JSON(["return":false, "code":"0"]))
                }
                break
            case .failure(let error):
                #if DEBUG
                print(error)
                #endif
                completion(JSON(["return":false, "code":"0", "message":"service_error".localized()]))
            }
        }
    }
    
    /*
    public func requestGET(_ path:String, params:[String : Any], completion: @escaping (_ result: JSON) -> Void) {
        
        if !Reachability.isConnectedToNetwork() {
            completion(JSON(["return":false, "code":"NET_MSG_0000"]))
            return
        }
        
        let headers:HTTPHeaders = ["Accept-Charset": "charset=UTF-8"]
        console.d(path, params)
        
        AF.request(path, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response:AFDataResponse<Any>) in
            
            #if DEBUG
            debugPrint(response)
            #endif
            
            switch response.result {
            case .success(let data):
                
                if String(describing: data).contains("error") {
                    
                    #if DEBUG
                    print("An error has occurred.")
                    #endif
                    
                    var message = JSON(data)["message"].stringValue
                    if "" == message {
                        message = "service_error".localized()
                    }
                    
                    completion(JSON(["return":false, "code":"API_MSG_0000", "message":message]))
                    break
                }
                
                let result = JSON(data)["status"].intValue
                
                if result == 0 {
                    
                    var message = JSON(data)["message"].stringValue
                    if "" == message {
                        message = "service_error".localized()
                    }
                    
                    completion(JSON(["return":false, "code":"API_MSG_0000", "message":message]))
                    break
                }
                
                completion( JSON(data) )
                break
            case .failure(let error):
                
                #if DEBUG
                print(error)
                #endif
                completion(JSON(["return":false, "code":"API_MSG_0000", "message":"service_error".localized()]))
            }
        }
    }
    */
}
