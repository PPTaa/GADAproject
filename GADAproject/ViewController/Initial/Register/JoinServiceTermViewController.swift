//
//  JoinServiceTermViewController.swift
//  GADA
//
//  Created by leejungchul on 2022/07/05.
//

import UIKit

class JoinServiceTermViewController: UIViewController {
    
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var btnTerms1: UIButton!
    @IBOutlet weak var btnTerms2: UIButton!
    @IBOutlet weak var btnTerms3: UIButton!
    @IBOutlet weak var btnTerms4: UIButton!
    
    @IBOutlet weak var moreTerms1: UIButton!
    @IBOutlet weak var moreTerms2: UIButton!
    @IBOutlet weak var moreTerms3: UIButton!
    @IBOutlet weak var moreTerms4: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinServiceTermViewController", #function)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    public func isValidate() -> Bool {
        
        if btnTerms1.isSelected && btnTerms2.isSelected && btnTerms3.isSelected {
            return true
        }
        
        return false
    }
    
    
    @IBAction func allClick(_ sender: UIButton) {
        
        btnAll.isSelected = !sender.isSelected
        
        if !sender.isSelected {
            btnTerms1.isSelected = false
            btnTerms2.isSelected = false
            btnTerms3.isSelected = false
            btnTerms4.isSelected = false
        } else {
            btnTerms1.isSelected = true
            btnTerms2.isSelected = true
            btnTerms3.isSelected = true
            btnTerms4.isSelected = true
        }
    }
    
    @IBAction func terms1Click(_ sender: UIButton) {
        
        btnTerms1.isSelected = !sender.isSelected
        btnAll.isSelected = false
    }
    
    @IBAction func terms2Click(_ sender: UIButton) {
        
        btnTerms2.isSelected = !sender.isSelected
        btnAll.isSelected = false
    }
    
    @IBAction func terms3Click(_ sender: UIButton) {
        
        btnTerms3.isSelected = !sender.isSelected
        btnAll.isSelected = false
    }
    
    @IBAction func terms4Click(_ sender: UIButton) {
        
        btnTerms4.isSelected = !sender.isSelected
        btnAll.isSelected = false
    }

    @IBAction func moreTermsClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "JoinMoreTermsViewController") as! JoinMoreTermsViewController
        if sender == self.moreTerms1 {
            vc.termTitle = "서비스 이용약관"
            vc.termSubTitle = "서비스 이용약관은"
            vc.termDescription = "text_term_1".localized()
        } else if sender == self.moreTerms2 {
            vc.termTitle = "개인정보 처리방침"
            vc.termSubTitle = "개인정보 처리방침은"
            vc.termDescription = "text_term_2".localized()
        } else if sender == self.moreTerms3 {
            vc.termTitle = "위치기반 서비스 이용약관"
            vc.termSubTitle = "위치기반 서비스 이용약관은"
            vc.termDescription = "text_term_3".localized()
        } else {
            vc.termTitle = "법정공지 및 정보제공처"
            vc.termSubTitle = "법정공지 및 정보제공처는"
            vc.termDescription = "text_term_4".localized()
        }
        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .fullScreen
        
        show(vc, sender: nil)
//        present(vc, animated: true, completion: nil)
    }
}

