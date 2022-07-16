//
//  UIFont.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/23.
//

import Foundation
import UIKit

extension UIFont {
    
    public enum fontType: String {
        case bold = "Bold"
//        case semiBold = "SemiBold"
        case medium = "Medium"
        case regular = "Regular"
//        case light = "Light"
    }
    
    static func notoSans(type: fontType, size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSansCJKkr-\(type)", size: size)!
    }
    
    static func montserrat(type: fontType, size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-\(type)", size: size)!
    }
    
    static func pretendard(type: fontType, size: CGFloat) -> UIFont {
        return UIFont(name: "Pretendard-\(type)", size: size)!
    }
}
