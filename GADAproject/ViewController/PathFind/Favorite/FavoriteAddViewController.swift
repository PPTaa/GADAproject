//
//  FavoriteAddViewController.swift
//  handycab
//
//  Created by leejungchul on 2021/09/02.
//

import UIKit
import RealmSwift
import TMapSDK

class FavoriteAddViewController: UIViewController {
    
    @IBOutlet weak var searchLocationTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let realm = try! Realm()
    
    var searchDataList = [SearchList]()
    var searchType = ""
    let dateFormatter = DateFormatter()
    
    var isHome = false
    var isUpdateHome = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchLocationTextfield.delegate = self
        
        if isHome {
            titleLabel.text = "집 등록"
        }
        
        if isUpdateHome {
            titleLabel.text = "집 수정"
        }
        
        searchLocationTextfield.addLeftPadding()
        UsefulUtils.roundingCorner(view: searchLocationTextfield, borderColor: UIColor(named: "color-gray-30") ?? .clear)
    }
    
    // 장소 검색 POI
    func search(keyword: String) {
        SLoader.showLoading()
        print("keyword : \(keyword)")
        self.searchDataList.removeAll()
        
        let pathData = TMapPathData()
        // POI 데이터 활용한 장소검색
        print("장소검색")
        
        pathData.requestFindAllPOI(keyword,count: 50) { (result, error) -> Void in

            guard let result = result else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    SLoader.hide()
                }
                return
            }
            for poi in result {
                let data: SearchList = SearchList(
                    name: poi.name!,
                    address: poi.address!,
                    lat: String(poi.coordinate!.latitude),
                    lon: String(poi.coordinate!.longitude),
                    bizName: poi.middleBizName!
                )
                self.searchDataList.append(data)
            }
            
            CATransaction.begin()
            DispatchQueue.main.async {
                print("SLoader end")
                SLoader.hide()
                self.tableView.reloadData()
            }
            CATransaction.commit()
        }
    }
    
    @IBAction func tapDeleteBtn(_ sender: Any) {
        searchLocationTextfield.text = ""
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension FavoriteAddViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let models = realm.objects(RecentSearch.self)
        switch section {
        case 0:
            return models.count > 3 ? 3 : models.count
        case 1:
            return searchDataList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let label: UILabel = {
            let text = UILabel()
            switch section {
            case 0:
                text.text = "최근 검색"
            case 1:
                text.text = "검색 결과"
            default:
                text.text = "section header"
            }
            text.font = UIFont(name: "NotoSansCJKkr-Bold", size: 12.0)
            text.textColor = .black
            text.translatesAutoresizingMaskIntoConstraints = false
            return text
        }()
        
        let button: UIButton = {
            let btn = UIButton()
            btn.setTitle("더보기", for: .normal)
            btn.titleLabel?.font = UIFont(name: "NotoSansCJKkr-light", size: 12.0)
            btn.setTitleColor(.black, for: .normal)
            btn.tag = section
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()
        
        let lineView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "color-gray-20") ?? .clear
            view.heightAnchor.constraint(equalToConstant: 2).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        headerView.addSubview(label)
        headerView.addSubview(button)
        headerView.addSubview(lineView)
        
        label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        
        button.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        button.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        button.addTarget(self, action: #selector(moreBtnClick), for: .touchUpInside)
        
        lineView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        lineView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableFooterView = UIView()
        // realm객체 읽어와서 객체들의 데이터 확인 및 표출 (R)
        let models = realm.objects(RecentSearch.self)
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! RecentSearchCell
            if models.count == 0 {
                return cell
            }
            cell.recentSearchName.text = models[models.count - indexPath.row - 1].name
            cell.recentSearchDate.text = models[models.count - indexPath.row - 1].date
            cell.deleteBtn.tag = models.count - indexPath.row - 1
            cell.deleteBtn.addTarget(self, action: #selector(deleteCellBtnClick), for: .touchUpInside)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
            cell.name.text = searchDataList[indexPath.row].name
            cell.address.text = searchDataList[indexPath.row].address
            cell.bizName.text = searchDataList[indexPath.row].bizName
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        let row = indexPath.row
        if indexPath.section == 0 {
            let models = realm.objects(RecentSearch.self)
            searchLocationTextfield.text = models[models.count - row - 1].name
            // 검색
            search(keyword: models[models.count - row - 1].name)
            // RecentSearch 객체의 realm객체 생성
            let recentSearch = RecentSearch()
            dateFormatter.dateFormat = "yy.MM.dd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            recentSearch.date = dateFormatter.string(from: Date())
            recentSearch.name = models[models.count - row - 1].name
            print("===",dateFormatter.string(from: Date()))
            // realm에 객체 작성 (C)
            try! realm.write {
                // realm DB에 추가 (C)
                realm.add(recentSearch)
            }
            
        } else {
            // MARK: 셀 클릭시 페이지 넘어가는 부분
            /*
            let lat = searchDataList[row].lat
            let lon = searchDataList[row].lon
            let name = searchDataList[indexPath.row].name
            let address = searchDataList[row].address
            let arrayVal = [searchType, name, lat, lon]
            
            let vc = UIStoryboard(name: "Path", bundle: nil).instantiateViewController(withIdentifier: "FavoriteConfirmViewController") as! FavoriteConfirmViewController
            print("Click검색결과\(searchDataList[row])")
            
            vc.isHome = isHome
            vc.isUpdateHome = isUpdateHome
            
            vc.myFavorite = searchDataList[row]
            vc.searchList = searchDataList
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
             */
        }
    }
    
    @objc func moreBtnClick(sender: CustomButton) {
        // MARK: 더보기 버튼 클릭시
        /*
        print("moreBtnClick Click \(sender.tag)")
        let vc = UIStoryboard(name: "PathFind", bundle: nil).instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        if sender.tag == 0 {
            vc.isRecentSearch = true
        } else {
            vc.isRecentSearch = false
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
         */
    }
    
    @objc func deleteCellBtnClick(sender: CustomButton) {
        print("sender.tag : \(sender.tag)")
        SLoader.showLoading()
        let models = realm.objects(RecentSearch.self)
        do {
            try realm.write {
                realm.delete(models[sender.tag])
            }
        } catch {
            print("error : \(error)")
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            print("donedonedonedonedone")
        }
        self.tableView.reloadData()
        CATransaction.commit()
        print("SLoader end")
        SLoader.hide()
    }
}


extension FavoriteAddViewController: UITextFieldDelegate {
    // 키보드 내리기(viewdidload에서 delegate설정을 해줘야 먹힘)
    // 키보드를 내리며 실행될 행동들
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        search(keyword: textField.text!)
        
        searchType = "end"
        
        let recentSearch = RecentSearch()
        recentSearch.name = textField.text!
        dateFormatter.dateFormat = "yy.MM.dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        recentSearch.date = dateFormatter.string(from: Date())
        try! realm.write {
            realm.add(recentSearch)
        }
        
        return true
    }
}
