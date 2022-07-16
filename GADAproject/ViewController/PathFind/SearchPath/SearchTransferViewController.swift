//
//  SearchTransferViewController.swift
//  GADA
//
//  Created by leejungchul on 2022/07/04.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher

class SearchTransferViewController: UIViewController {
    
    @IBOutlet weak var transferImage: UIImageView!
    @IBOutlet weak var transferStation: UILabel!
    @IBOutlet weak var startLnCd: UIImageView!
    @IBOutlet weak var endLnCd: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var baseScale: CGFloat = 1.0
    var minScale: CGFloat = 1.0
    
    let tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    var transferInfo = [[TransferInfo]]()
    var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TransferViewController viewDidLoad")
        
        setupTableView()
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch))
        self.view.addGestureRecognizer(pinch)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(doPanGesture))
        transferImage.addGestureRecognizer(panGesture)
                
        NotificationCenter.default.addObserver(self, selector: #selector(receiveTransferInfo(_:)), name: .receiveTransferInfo, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .receiveTransferInfo, object: nil)
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: transferImage.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.register(TransferCell.self, forCellReuseIdentifier: TransferCell.cellId)
    }
    
    @IBAction func backBtnClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension SearchTransferViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transferInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: TransferCell.cellId, for: indexPath) as! TransferCell

        print("___________________________________")
        cell.data = transferInfo[row]
        cell.title.sizeToFit()
        let newsize = cell.title.sizeThatFits(CGSize(width: cell.title.frame.width, height: CGFloat.greatestFiniteMagnitude))
        print("newsize : \(newsize)")
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        
        for i in 0 ..< transferInfo.count {
            if i == selectedIndex.row {
                transferInfo[i][0].isSelected = true
            } else {
                transferInfo[i][0].isSelected = false
            }
        }
        print("self.transferInfo[selectedIndex.row] : \(self.transferInfo[selectedIndex.row])")
        if self.transferInfo[selectedIndex.row].count == 1 {
            print("sssss")
            return
        }
        let imageUrl = URL(string: self.transferInfo[selectedIndex.row][1].imgPath)
        self.transferImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "NullImage"))
        tableView.beginUpdates()
        tableView.reloadRows(at: [selectedIndex], with: .none)
        tableView.endUpdates()
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if selectedIndex == indexPath {
            if !transferInfo[row][0].isSelected {
                return 64
            } else {
                return CGFloat(64 + Double(transferInfo[row].count * 22))
            }
        }
        return 64
    }
}



extension SearchTransferViewController {
    // 환승 이동경로(표준) API
    func transferMovementCall(chthTgtLn: String, chtnNextStinCd: String, railOprIsttCd: String, lnCd: String, stinCd: String, prevStinCd: String) {
        print("환승 이동경로 (표준) API")
        let body : Parameters = [
        "serviceKey": "$2a$10$o/DL6MPbsjRS2llxGiiOH.wSfVCQ12fX35EXR39AlcGWAtztWle0O",
        "format": "json",
        "chthTgtLn": chthTgtLn, // 환승대상선
        "chtnNextStinCd": chtnNextStinCd, // 환승이후역코드
        "railOprIsttCd": railOprIsttCd, // 철도운영기관코드
        "lnCd": lnCd, // 선코드
        "stinCd": stinCd, // 역코드
        "prevStinCd": prevStinCd, // 이전역코드
        ]
        
        AF.request("http://openapi.kric.go.kr/openapi/handicapped/transferMovement",parameters: body, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let data) :
                let json = JSON(data)
                let jsonHeader = json["header"].dictionaryValue
                let jsonBody = json["body"].arrayValue
                var prevMvPathMgNo = ""
                var countKinds = 0
                var imageUrl: URL?
                print(json)
                if jsonHeader["resultCode"]?.stringValue == "03" {
                    self.transferInfo.append([TransferInfo(isSelected: true, mvPathMgNo: "", elvtSttCd: "", imgPath: "", edMovePath: "", elvtTpCd: "", chtnMvTpOrdr: "", mvContDtl: "null", stMovePath: "")])
                    self.transferImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "NullImage"))
                    self.tableView.reloadData()
                    break
                }
                for (idx,i) in jsonBody.enumerated() {
                    
                    if idx == 0 {
                        
                        self.transferInfo.append([TransferInfo(isSelected: true, mvPathMgNo: "", elvtSttCd: "", imgPath: "", edMovePath: "", elvtTpCd: "", chtnMvTpOrdr: "", mvContDtl: "", stMovePath: "")])
                    } else {
                        prevMvPathMgNo = jsonBody[idx-1]["mvPathMgNo"].stringValue
                        if prevMvPathMgNo != i["mvPathMgNo"].stringValue {
                            self.transferInfo.append([TransferInfo(isSelected: false, mvPathMgNo: "", elvtSttCd: "", imgPath: "", edMovePath: "", elvtTpCd: "", chtnMvTpOrdr: "", mvContDtl: "", stMovePath: "")])
                            countKinds += 1
                        }
                    }
                    self.transferInfo[countKinds].append(TransferInfo(mvPathMgNo: i["mvPathMgNo"].stringValue, elvtSttCd: i["elvtSttCd"].stringValue, imgPath: i["imgPath"].stringValue, edMovePath: i["edMovePath"].stringValue, elvtTpCd: i["elvtTpCd"].stringValue, chtnMvTpOrdr: i["chtnMvTpOrdr"].stringValue, mvContDtl: i["mvContDtl"].stringValue, stMovePath: i["stMovePath"].stringValue))
                }
                        
                if self.transferInfo.count > 0 {
                    imageUrl = URL(string: self.transferInfo[0][1].imgPath)
                }
                
                self.transferImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "NullImage"))
                guard let imageUrl = imageUrl else { return }
                
                // imageView Size 조절
                let tempUrl = ImageResource(downloadURL: imageUrl)
                KingfisherManager.shared.retrieveImage(with: tempUrl, options: nil, progressBlock: nil) { result in
                    switch result {
                    case .success(let value):
                        print("Image size: \(value.image.size). Got from: \(value.cacheType)")
                        let ratio = value.image.size.height / value.image.size.width
                        self.imageHeight.constant = self.transferImage.frame.width * ratio
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                
                self.tableView.reloadData()
                break
            case .failure(let error):
                print("error: \(error)")
                break
            }
        }
    }
}

extension SearchTransferViewController {
    @objc func receiveTransferInfo(_ notification: Notification) {
        let item: TransferData = notification.object as! TransferData
        transferMovementCall(chthTgtLn: item.chthTgtLn, chtnNextStinCd: item.chtnNextStinCd, railOprIsttCd: item.railOprIsttCd, lnCd: item.lnCd, stinCd: item.stinCd, prevStinCd: item.prevStinCd)
        let end = SubwayUtils.shared().laneCdChange(laneCd: item.chthTgtLn)
        let start = SubwayUtils.shared().laneCdChange(laneCd: item.lnCd)
        endLnCd.image = UIImage(named: "subwaySquare-\(end)")
        startLnCd.image = UIImage(named: "subwaySquare-\(start)")
        transferStation.text = "\(item.stinNm)역 환승경로"
    }
    
    // MARK: 제스쳐 관련 함수
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        if baseScale > minScale && pinch.scale < 1.0 {
            transferImage.transform = transferImage.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            baseScale *= pinch.scale
            pinch.scale = 1.0

        } else if pinch.scale > 1.0  {
            transferImage.transform = transferImage.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            baseScale *= pinch.scale
            pinch.scale = 1.0
        }
    }
    
    @objc func doPanGesture(_ sender: UIPanGestureRecognizer) {
        let draggedView = sender.view!
        let translation = sender.translation(in: self.view)
        print(sender.view?.center.x)
        print(sender.view?.center.y)
        draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
}

// UITableView 코드로 작성
class TransferCell: UITableViewCell {
    
    static let cellId = "TransferCell"
    
    var data: [TransferInfo]? {
        didSet {
            guard let data = data else { return }
            var titleText = ""
            var detailText = ""
            for (i,v) in data.enumerated() {
                print(v)
                if v.mvContDtl == "" {
                    continue
                } else if v.mvContDtl == "null" {
                    titleText = "죄송합니다. 역사 환승정보가 없습니다."
                    continue
                }
                if i == data.count - 1 {
                    detailText += "\(v.mvContDtl)"
                } else {
                    detailText += "\(v.mvContDtl)\n"
                }
                titleText = "\(v.stMovePath) -> \(v.edMovePath)"
            }
            print("data : \(detailText), title: \(titleText)")
            self.title.text = titleText
            self.detail.text = detailText
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-Medium", size: 16.0)
        label.text = "title"
        label.textAlignment = .left
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let detail: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NotoSansCJKkr-light", size: 14.0)
        label.text = "detail"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(container)
        container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        container.addSubview(title)
        container.addSubview(detail)

        title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 25).isActive = true
        title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -25).isActive = true
        title.topAnchor.constraint(equalTo: container.topAnchor, constant: 20).isActive = true
        title.heightAnchor.constraint(equalToConstant: 23).isActive = true
        
        detail.leadingAnchor.constraint(equalTo: title.leadingAnchor, constant: 0).isActive = true
        detail.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: 0).isActive = true
        detail.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 21).isActive = true
        detail.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
    }
    
}

struct TransferInfo {
    var isSelected: Bool = false
    var mvPathMgNo: String
    var elvtSttCd : String
    var imgPath : String
    var edMovePath : String
    var elvtTpCd : String
    var chtnMvTpOrdr : String
    var mvContDtl : String
    var stMovePath : String
}
