//
//  UsefulUtils.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import Foundation
import UIKit

class UsefulUtils {
    
    class func roundingCorner(view: AnyObject, borderColor: UIColor = .clear) {
        if let view = view as? UIView{
            view.layer.cornerRadius = view.frame.size.height / 2
            view.layer.borderWidth = 1
            view.layer.borderColor = borderColor.cgColor
            view.clipsToBounds = true
        } else if let image = view as? UIImageView {
            image.layer.cornerRadius = image.frame.size.height / 2
            image.layer.borderWidth = 1
            image.layer.borderColor = borderColor.cgColor
            image.clipsToBounds = true
        } else if let button = view as? UIButton {
            button.layer.cornerRadius = button.frame.size.height / 2
            button.layer.borderWidth = 1
            button.layer.borderColor = borderColor.cgColor
            button.clipsToBounds = true
        }
    }
    
    class func shadowCorner(view: AnyObject, shadowOpacity: Float = 0.15, radius: CGFloat = 10) {
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = radius
        view.layer.masksToBounds = false
    }
    
    class func callTo(phoneNumber: String) -> Bool {
        guard !phoneNumber.isEmpty else { return false }
        guard let phoneNumberUrl = URL(string: "tel://\(phoneNumber)") else { return false }
        UIApplication.shared.open(phoneNumberUrl, options: [:], completionHandler: nil)
        return true
    }
    
    class func openAppStore(appId: String) {
        let url = "itms-apps://itunes.apple.com/app/" + appId;
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
