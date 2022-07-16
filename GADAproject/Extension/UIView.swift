//
//  UIView.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import Foundation
import UIKit

extension UIView {
    func roundCorner(radius: CGFloat, arrayLiteral: CACornerMask.ArrayLiteralElement = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) {
        
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = CACornerMask(arrayLiteral: arrayLiteral)
        self.clipsToBounds = true
    }
    
    func loadView(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    var mainView: UIView? {
        return subviews.first
    }
    
    func constraintWith(identifier: String) -> NSLayoutConstraint? {
        return self.constraints.first(where: {$0.identifier == identifier})
    }
    
    @objc func roundCorners(corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }
    
    /**
     - note: Dash or Dotted 라인
     - parameters:
        - frameWidth: 뷰 너비
        - lineWidth: Dash or Dotted 간격
        - color: 라인 컬러
     */
    func createDottedLine(lineWidth: CGFloat, color: CGColor) {
       let caShapeLayer = CAShapeLayer()
       caShapeLayer.strokeColor = color
       caShapeLayer.lineWidth = lineWidth
       caShapeLayer.lineDashPattern = [4,4]
       let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: self.frame.height)]
       cgPath.addLines(between: cgPoint)
       caShapeLayer.path = cgPath
       layer.addSublayer(caShapeLayer)
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
    
    public func removeAllSubViews() {
        self.subviews.forEach({ $0.removeFromSuperview()})
    }
    
    var id: String? {
        get {
            return self.accessibilityIdentifier
        }
        set {
            self.accessibilityIdentifier = newValue
        }
    }

    func view(withId id: String) -> UIView? {
        if self.id == id {
            return self
        }
        for view in self.subviews {
            if let view = view.view(withId: id) {
                return view
            }
        }
        return nil
    }
}
