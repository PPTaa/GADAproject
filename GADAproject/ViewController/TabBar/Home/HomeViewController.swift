//
//  HomeViewController.swift
//  GADAproject
//
//  Created by leejungchul on 2022/07/13.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapGotoPathFind(_ sender: Any) {
        let vc = UIStoryboard(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func tapThemeSwitch(_ sender: UISwitch) {
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if sender.isOn {
                appDelegate?.overrideUserInterfaceStyle = .dark
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
            }
        } else {
            // Fallback on earlier versions
            
        }
        
    }
}


/*
 카테고리
 POP 강수확률 (%) "60"
 PTY 강수형태 (코드값) "1" (0: 없음, 1: 비, 2: 비/눈, 3: 눈, 4: 소나기)
 PCP 1시간 강수량 (mm) "2.0mm"
 REH 습도 (%) "90"
 SNO 1시간 신적설 (cm) "적설없음"
 SKY 하늘상태 (코드값) "4" (1: 맑음, 3: 구름많음, 4:흐림)
 TMP 1시간 기온 (°C) "24"
 TMN 일 최저 기온 (°C) ""
 TMX 일 최고 기온 (°C) ""
 UUU 풍속(동서) (m/s) "-3.1"
 VVV 풍속(남북) (m/s) "1.5"
 WAV 파고 (M) "0"
 VEC 풍향 (deg) "116"
 WSD 풍속 (m/s) "3.6"
 */

/*
 아래 링크 활용해서 지역 지정하기
https://velog.io/@chaeri93/Django-%EA%B8%B0%EC%83%81%EC%B2%AD-%EB%8B%A8%EA%B8%B0%EC%98%88%EB%B3%B4-API-%ED%99%9C%EC%9A%A9%ED%95%98%EA%B8%B0
*/
