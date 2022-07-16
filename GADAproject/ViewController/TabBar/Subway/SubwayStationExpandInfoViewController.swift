//
//  SubwayStationExpandInfoViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import UIKit
import Kingfisher

class SubwayStationExpandInfoViewController: UIViewController {

    @IBOutlet weak var reductImageBtn: UIButton!
    @IBOutlet weak var stationInfoImage: UIImageView!
    
    var baseScale: CGFloat = 1.0
    var minScale: CGFloat = 1.0
    
    var stationImageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageSetting()
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch))
        self.view.addGestureRecognizer(pinch)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(doPanGesture))
        stationInfoImage.addGestureRecognizer(panGesture)
        
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageSetting() {
        print("stationImageURL : \(stationImageURL)")
        let imageUrl = URL(string: stationImageURL) ?? URL(string: "")
        
        self.stationInfoImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "subway_no_img"))
        self.stationInfoImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        
        UsefulUtils.roundingCorner(view: reductImageBtn)
        UsefulUtils.shadowCorner(view: reductImageBtn, shadowOpacity: 0.25)

    }
    

}


// MARK: 제스쳐 관련 익스텐션
extension SubwayStationExpandInfoViewController {
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        if baseScale > minScale && pinch.scale < 1.0 {
            stationInfoImage.transform = stationInfoImage.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            baseScale *= pinch.scale
            pinch.scale = 1.0

        } else if pinch.scale > 1.0  {
            stationInfoImage.transform = stationInfoImage.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            baseScale *= pinch.scale
            pinch.scale = 1.0
        }
    }
    
    @objc func doPanGesture(_ sender: UIPanGestureRecognizer) {
        let draggedView = sender.view!
        let translation = sender.translation(in: self.view)
        draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
}
