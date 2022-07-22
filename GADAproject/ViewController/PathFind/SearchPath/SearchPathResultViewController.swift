//
//  SearchPathResultViewController.swift
//  GADA
//
//  Created by leejungchul on 2022/07/01.
//

import Foundation
import TMapSDK
import SwiftyJSON
import FloatingPanel
import UIKit
import CoreLocation

class SearchPathResultViewController: UIViewController, TMapViewDelegate, FloatingPanelControllerDelegate {
    
    @IBOutlet weak var tmapView: UIView!
    @IBOutlet weak var tmapViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
//    @IBOutlet weak var nowLocationBtn: UIButton!
    
    
    // 경로탐색 결과 폴리라인 리스트
    var polylines = [TMapPolyline]()
    var totalExitLatLon = [(startExitLatLon: CLLocationCoordinate2D, endExitLatLon: CLLocationCoordinate2D, busNo: String)]()
    var detailPathData = [SearchPathData]()
    
    // Tmap 표출
    var mapView: TMapView?
    
    // floating view
    var fpc: FloatingPanelController!
    var contentVC: FloatingViewController!
    
    // marker
    var markers = [TMapMarker]()
    var topMarkers = [TMapCustomMarker]()
    // now marker
    var nowMarkers = [TMapMarker]()
    var isCompassMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView = TMapView(frame: tmapView.frame)
        self.mapView?.delegate = self
        self.mapView?.setApiKey(BaseConst.MAP_API_KEY)
        
        UsefulUtils.roundingCorner(view: backBtn)
        UsefulUtils.shadowCorner(view: backBtn)
        
//        UsefulUtils.roundingCorner(view: nowLocationBtn)
//        UsefulUtils.shadowCorner(view: nowLocationBtn)
        
        tmapView.addSubview(self.mapView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(returnMapObj(_:)), name: .returnMapObj , object: nil)
        
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .returnMapObj, object: nil)
        
    }
    
    func setupView() {
        contentVC = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "FloatingViewController") as? FloatingViewController
        fpc = FloatingPanelController()
        fpc.changePanelStyle()
        fpc.delegate = self
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: self)
        fpc.layout = PathFloatingPanelLayout()
        fpc.invalidateLayout()
        
        if (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! > CGFloat(0.0) {
            
            print("if : \(UIApplication.shared.keyWindow?.safeAreaInsets.bottom)")
            guard let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {return}
            print("if : \(safeArea)")
            tmapViewHeightConst.constant = fpc.surfaceLocation(for: .tip).y - safeArea + 10
        } else {
            print("else : \(UIApplication.shared.keyWindow?.safeAreaInsets.bottom)")
            tmapViewHeightConst.constant = fpc.surfaceLocation(for: .tip).y + 10
        }
    }
    
    // floating panel 아래 고정
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if fpc.isAttracting == false {
            let loc = fpc.surfaceLocation
            let minY = fpc.surfaceLocation(for: .full).y
            let maxY = fpc.surfaceLocation(for: .tip).y
            fpc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
        }
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        print("click")
        dismiss(animated: true, completion: nil)
    }
    /*
    // 한번 탭
    @IBAction func nowLoactionClick(_ sender: Any) {
        print("\(SearchViewController.currentLocation)")
        if SearchViewController.currentLocation.latitude == 0.0 && SearchViewController.currentLocation.longitude == 0.0 {
            return
        }
        getLocation(location: SearchViewController.currentLocation)
    }
    
    // 두번탭
    @IBAction func nowLocationDoubleTap(_ sender: Any) {
        if isCompassMode {
            mapView?.setCompassMode(false)
            isCompassMode = false
        } else {
            mapView?.setCompassMode(true)
            isCompassMode = true
        }
    }
     */
    
    func getLocation(location: CLLocationCoordinate2D) {
        
        removeNowMarker()
        // 현위치로 이동
        self.mapView?.animateTo(location: location)
        // 현 위치에 마커 생성
        let marker = TMapMarker(position: location)
        // 지도에 마커 적용
        marker.icon = UIImage(named: "compassLocation")
        marker.map = self.mapView
        self.nowMarkers.append(marker)
        
    }
    
    // 마커제거 함수화
    func removeNowMarker() {
        for marker in nowMarkers {
            marker.map = nil
        }
        nowMarkers.removeAll()
    }
}

extension SearchPathResultViewController {
    // mapObj 전달
    @objc func returnMapObj(_ notification: Notification) {
        let item = notification.object as! SearchPathModel
        
        print("noti-----", item)
        print("noti-----", item.seName)
        print("noti-----", item.totalTime)
        print("noti-----", item.detailPathData)
        print("noti-----", item.busID)
        print("noti-----", item.busNo)
        detailPathData = item.detailPathData
        for exitData in item.exitLatLon {
            totalExitLatLon.append((startExitLatLon: CLLocationCoordinate2D(latitude: exitData.startExitLat, longitude: exitData.startExitLon), endExitLatLon: CLLocationCoordinate2D(latitude: exitData.endExitLat, longitude: exitData.endExitLon), busNo: exitData.busNo))
        }
        print("+++++++++++\(totalExitLatLon)")
        
        searchDetailPath(mapObj: item.mapObj)
        
        let startMarker = TMapMarker(position: SearchViewController.startLatLon)
        startMarker.icon = UIImage(named: "location_origin_24")
        startMarker.map = self.mapView
        self.markers.append(startMarker)
        
        let endMarker = TMapMarker(position: SearchViewController.endLatLon)
        endMarker.icon = UIImage(named: "location_destination_24")
        endMarker.map = self.mapView
        self.markers.append(endMarker)
    }
}

// ODSay + Tmap 호출 함수 모음
extension SearchPathResultViewController {
    
    //odsay 경로 라인 호출함수
    func searchDetailPath(mapObj: String) {
        print(mapObj)
        // 라인제거
        for polyline in self.polylines {
            polyline.map = nil
        }
        self.polylines.removeAll()
        for i in SearchPathResultModel.tmapPolyLine {
            i.map = nil
        }
        SearchPathResultModel.tmapPolyLine.removeAll()
        
        // 경로 탐색
        ODsayService.sharedInst().requestLoadLane("0:0@\(mapObj)") { (retCode: Int32, resultDict: [AnyHashable : Any]?) in
            if retCode == 200 {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: resultDict!, options: .prettyPrinted)
                    let getInstanceData = try JSONDecoder().decode(requestLoadLaneResult.self, from: jsonData)
                    guard let result = getInstanceData.result else { return }
                    var lastRouteEnd: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                    var lastTrafficClass: Int = 0
                    print("result : ", result)
                    for (index, i) in result.lane.enumerated() {
                        var coordnates: Array<CLLocationCoordinate2D> = Array()
                        let exitIndex = index * 2 + 1
                        
                        for j in i.section[0].graphPos {
                            coordnates.append(CLLocationCoordinate2D(latitude: j.y, longitude: j.x))
                        }
                        // 현재 경로의 시작점(지하철일경우 입구)
                        let startCoord = i.trafficClass == 2 ? self.totalExitLatLon[exitIndex].startExitLatLon : coordnates.first!
                        // 현재 경로의 끝점(지하철일경우 출구)
                        let endCoord = i.trafficClass == 2 ? self.totalExitLatLon[exitIndex].endExitLatLon : coordnates.last!
                        
                        if index == 0 {
                            self.searchPath(startLatLon: SearchViewController.startLatLon, endLatLon: startCoord, idx: index)
                        } else {
                            // 지난 교통수단과 현재교통수단이 같지 않거나, 현재교통수단이 지하철이 아닌경우에만 탐색
                            if lastTrafficClass != i.trafficClass || i.trafficClass != 2 {
                                // 지난수단의 마지막 좌표와 현재 출발 좌표가 같지 않을 경우에만 탐색
                                if lastRouteEnd.longitude != startCoord.longitude {
                                    self.searchPath(startLatLon: lastRouteEnd, endLatLon: startCoord, idx: index)
                                }
                            }
                        }
                        
                        if index == result.lane.count - 1 {
                            self.searchPath(startLatLon: endCoord, endLatLon: SearchViewController.endLatLon, idx: index)
                        }
                        
                        if i.trafficClass == 2 {
                            lastRouteEnd = self.totalExitLatLon[exitIndex].endExitLatLon
                        } else {
                            lastRouteEnd = coordnates.last!
                        }
                        lastTrafficClass = i.trafficClass
                        

                        // 각 교통수단 별 마커 표시
                        let startMarker = TMapMarker(position:coordnates.first!)
                        
                        if i.trafficClass == 1 {
                            startMarker.icon = UIImage(named: "circle_bus_24")
                        } else {
//                            startMarker.icon = UIImage(named: "mapSubwayLine\(i.type)")
                            let changeCode = SubwayUtils.shared().laneCdChange(laneCd: "\(i.type)")
                            print("circle_line_\(changeCode)_24")
                            startMarker.icon = UIImage(named: "circle_line_\(changeCode)_24")
                        }

                        DispatchQueue.main.async {
//                            startTopMarker.map = self.mapView
//                            startTopMarker.offset = CGSize(width: 12.5, height: -22)
                            
                            startMarker.map = self.mapView
                            startMarker.offset = CGSize(width: 12.5, height: 10)
                            
//                            self.topMarkers.append(startTopMarker)
                            self.markers.append(startMarker)

                        }
                        // 경로 폴리라인으로 그리기
                        let line = TMapPolyline(coordinates: coordnates)
                        if i.trafficClass == 1 {
                            print("버스")
                            line.lineStyle = .solid
                            line.strokeColor = .black
                        } else if i.trafficClass == 2 {
                            print("지하철")
                            line.lineStyle = .solid
                            line.strokeColor = UIColor(named: "color-\(i.type)") ?? .gray
                        }
                        SearchPathResultModel.tmapPolyLine.append(line)
                    }


                    DispatchQueue.main.async {
                        print("dispatch")
                        for i in SearchPathResultModel.tmapPolyLine {
                            i.map = self.mapView
                            self.polylines.append(i)
                        }
                        let mapBound = MapBounds(sw: SearchViewController.endLatLon, ne: SearchViewController.startLatLon)
                        self.mapView?.fitBounds(mapBound, padding: 70)
//
                    }

                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    @objc func tapBtnTest() {
        print("tap")
    }
    
    func searchPath(startLatLon: CLLocationCoordinate2D, endLatLon: CLLocationCoordinate2D, idx: Int) {
        
        print("func searchPath \(startLatLon) , \(endLatLon)")
        
        let pathData = TMapPathData()
        pathData.findPathDataWithType(.PEDESTRIAN_PATH, startPoint: startLatLon, endPoint: endLatLon) { (result, error) -> Void in
            print("_______ \(idx) _____result \(result)")
            print("_______ \(idx) _____error \(error)")
            if let polyline = result {
                DispatchQueue.main.async {
                    polyline.lineStyle = .dot
                    polyline.strokeColor = UIColor.gray
                    polyline.strokeWidth = 2.5
                    polyline.map = self.mapView
                    self.polylines.append(polyline)
                }
            }
        }
    }
}

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -4.0)
        shadow.opacity = 0.15
        shadow.radius = 2
        appearance.shadows = [shadow]
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        appearance.borderColor = .clear
        appearance.borderWidth = 0

//        surfaceView.grabberHandle.isHidden = true
        surfaceView.appearance = appearance
    }
}
