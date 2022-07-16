//
//  TriangleView.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/28.
//

import Foundation
import UIKit

class TriangleView: UIView {

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.close()
        UIColor.white.set()
        path.fill()
    }
    
    
}
