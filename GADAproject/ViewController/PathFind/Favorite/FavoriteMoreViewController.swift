//
//  FavoriteMoreViewController.swift
//  GADA
//
//  Created by leejungchul on 2022/06/30.
//

import UIKit
import Alamofire

// 즐겨찾기 수정 탭 구현예정
class FavoriteMoreViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var confirmDialog:ConfirmPopupView!
    
    var isHomeExist = false
    
//    var favoriteDao = DataShare.shared().favoriteDao
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if DataShare.shared().favoriteDataList[1].name != "" {
            isHomeExist = true
        } else {
            isHomeExist = false
        }
        print("viewWillAppear / reloadData")
        tableView.reloadData()
    }
    
    @IBAction func backBtnClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension FavoriteMoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return favoriteDao.count
        return DataShare.shared().favoriteDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        let row = indexPath.row + 1
//        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteMoreCell", for: indexPath) as! FavoriteMoreCell
//        let addCell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! AddCell
//        if row == DataShare.shared().favoriteDataList.count {
//            UsefulUtils.roundingCorner(view: addCell.addBtn, borderColor: UIColor(named: "color-gray-30") ?? .clear)
//            addCell.addBtn.addTarget(self, action: #selector(addBtnClick), for: .touchUpInside)
//            addCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//            return addCell
//        }
        cell.favoriteLocationCustomName.text = DataShare.shared().favoriteDataList[row].customName
        cell.favoriteLocationName.text = DataShare.shared().favoriteDataList[row].name
        cell.favoriteLocationAddress.text = DataShare.shared().favoriteDataList[row].address
        print("favoriteDao[row].address : \(DataShare.shared().favoriteDataList[row].address)")
        if DataShare.shared().favoriteDataList[row].name == "" {
            cell.updateBtn.isHidden = true
            cell.deleteBtn.isHidden = true
            cell.lineView.isHidden = true
            cell.favoriteLocationName.text = "등록된 장소가 없습니다."
        } else {
            cell.updateBtn.isHidden = false
            cell.deleteBtn.isHidden = false
            cell.lineView.isHidden = false
        }
        
        switch DataShare.shared().favoriteDataList[row].customName {
        case "현위치":
            cell.favoriteLocationIcon.image = UIImage(named: "icNowLocation")
        case "집":
            cell.favoriteLocationIcon.image = UIImage(named: "icHome")
        case "추가하기":
            cell.favoriteLocationIcon.image = UIImage(named: "icPlus")
        default:
            cell.favoriteLocationIcon.image = UIImage(named: "icNewLocation")
        }
            
        cell.updateBtn.tag = row
        cell.updateBtn.addTarget(self, action: #selector(updateBtnClick), for: .touchUpInside)
        cell.deleteBtn.tag = row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClick), for: .touchUpInside)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        if row == 0 {
            if !isHomeExist {
                let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteAddViewController") as! FavoriteAddViewController
                vc.modalPresentationStyle = .fullScreen
                vc.isHome = true
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func addBtnClick(_ sender: CustomButton) {
        print("addBtnClick")
        let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteAddViewController") as! FavoriteAddViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    @objc func updateBtnClick(_ sender: CustomButton) {
        // MARK: 용도 확인후 재 구축
        // 집 수정시
//        if sender.tag == 1 {
//            let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteAddViewController") as! FavoriteAddViewController
//            vc.modalPresentationStyle = .fullScreen
//            vc.isUpdateHome = true
//            present(vc, animated: true, completion: nil)
//            return
//        }
//        let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteConfirmViewController") as! FavoriteConfirmViewController
//        let (name, address, lat, lon) = (favoriteDao[sender.tag].name, favoriteDao[sender.tag].address, favoriteDao[sender.tag].lat, favoriteDao[sender.tag].lon)
//        vc.isUpdate = true
//        vc.updateIndex = sender.tag
//        vc.myFavorite = SearchList(name: name, address: address, lat: String(lat), lon: String(lon), bizName: "")
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true, completion: nil)
    }
    
    @objc func deleteBtnClick(_ sender: CustomButton) {
        if confirmDialog != nil { confirmDialog.dismiss(animated: false, completion: nil) }
        confirmDialog = (UIStoryboard.init(name: "Popup", bundle: nil).instantiateViewController(withIdentifier: "ConfirmPopupView") as! ConfirmPopupView)
        confirmDialog.modalTransitionStyle = .crossDissolve
        confirmDialog.modalPresentationStyle = .overCurrentContext

        confirmDialog.descString = "정말 삭제하시겠습니까?"
        confirmDialog.cancelString = "cancel".localized()
        confirmDialog.confirmString = "confirm".localized()
        confirmDialog.confirmClick = { () -> () in
            self.deleteConfirm(selectIdx: sender.tag)
            self.tableView.reloadData()
        }
        confirmDialog.cancelClick = { () -> () in
        }
        present(confirmDialog, animated: true, completion: nil)
    }
    
    private func deleteConfirm(selectIdx: Int) {
        // MARK: 즐겨찾기부분 전반적으로 손봐야할 필요성 있음.
        print(selectIdx)
        let nickName = DataShare.shared().profileDao.name
        let idx = DataShare.shared().favoriteDataList[selectIdx].idx
//        let idx = favoriteDao[selectIdx].idx
        // 집 삭제시
        if selectIdx == 1 {
//            favoriteDao[selectIdx].address = ""
//            favoriteDao[selectIdx].lat = 0.0
//            favoriteDao[selectIdx].lon = 0.0
//            favoriteDao[selectIdx].name = ""
            
            DataShare.shared().favoriteDataList[selectIdx].address = ""
            DataShare.shared().favoriteDataList[selectIdx].lat = 0.0
            DataShare.shared().favoriteDataList[selectIdx].lon = 0.0
            DataShare.shared().favoriteDataList[selectIdx].name = ""
//            FavoriteAPI.update_fl(nickName: nickName, customName: "집", name: "", address: "", lat: 0.0, lon: 0.0, idx: idx) { result in }

            // MARK: nickname이 없어서 그에 따른 분기가 필요함.
            let params: [String:Any] = [
                "nickname" : nickName,
                "customname" : "집",
                "name" : "",
                "address" : "",
                "lat" : 0.0,
                "lon" : 0.0,
                "idx" : idx
            ]
            print("nickName - \(nickName)")
            let path = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_FAVORITE_UPDATE
            
            AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString).responseJSON { response in

                switch response.result {
                case .success(let result):
                    print("success : \(result)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            isHomeExist = false
            return
        }
        
//        FavoriteAPI.delete_fl(idx: idx) { result in
//            print("delete result = \(result)")
//        }
         
        // MARK: nickname이 없어서 그에 따른 분기가 필요함.
        let params: [String:Any] = [
            "idx" : idx
        ]
        print("nickName - \(nickName)")
        let path = BaseConst.SERVICE_SERVER_HOST + BaseConst.NET_FAVORITE_DELETE
        
        AF.request(path, method: .post, parameters: params, encoding: URLEncoding.queryString).responseJSON { response in
            switch response.result {
            case .success(let result):
                print("success : \(result)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        print("____deleteData Complete____")
//        DataShare.shared().favoriteDao.remove(at: selectIdx)
//        favoriteDao.remove(at: selectIdx)
//        DataShare.shared().favoriteName.remove(at: selectIdx)
        DataShare.shared().favoriteDataList.remove(at: selectIdx)
        print("favoriteDao.remove Complete____")
    }
}

class FavoriteMoreCell: UITableViewCell {
    @IBOutlet weak var favoriteLocationIcon: UIImageView!
    @IBOutlet weak var favoriteLocationCustomName: UILabel!
    @IBOutlet weak var favoriteLocationName: UILabel!
    @IBOutlet weak var favoriteLocationAddress: UILabel!
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
}

class AddCell: UITableViewCell {
    @IBOutlet weak var addBtn: UIButton!
}
