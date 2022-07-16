//
//  UIButton.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/30.
//

import Foundation
import UIKit
import ObjectiveC


var disabledColorHandle: UInt8 = 0
var highlightedColorHandle: UInt8 = 0
var selectedColorHandle: UInt8 = 0

@IBDesignable
extension UIButton {

    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
    
    func roundCorners(corners: UIRectCorner, radius: Int = 8) {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func setAnimateBackgroundColor(color: UIColor, duration:Float) {
        
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.layer.backgroundColor =  color.cgColor
        }
    }
    
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        // NSAttributedStringKey.foregroundColor : UIColor.blue
        // attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        // attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setState(_ bool:Bool) {
        if bool {
            self.isEnabled = true
            self.alpha = 1.0
        }else {
            self.isEnabled = false
            self.alpha = 0.25
        }
    }
    
    func paddingLeft(left: CGFloat) {
        titleEdgeInsets.left = left
    }
}

class CustomButton: UIButton {
    
    var isTrue: Bool?
    var isTransfer: Bool?
    var nextStinNm: String?
    var prevStinNm: String?
    var isRecentSearch: Bool = true
    var idx: Int = 0
    var laneCd: String?
    
}
