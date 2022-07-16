import UIKit
import SwiftyJSON
import SwiftyUserDefaults


/**
 - note: 
 */
class JoinHandicabViewController: UIViewController {
    
    @IBOutlet weak var tvPage:UILabel!
    @IBOutlet weak var tvTitle:UILabel!
    @IBOutlet weak var btnAble1:UIButton!
    @IBOutlet weak var btnAble2:UIButton!
    @IBOutlet weak var btnAble3:UIButton!
    @IBOutlet weak var btnAble4:UIButton!
    
    private var hc_type: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JoinHandicabViewController", #function)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func able1Click(_ sender: UIButton) {
        if btnAble1.isSelected {
            deSelectbtn(button: btnAble1)
            hc_type.removeAll(where: { $0 == "1" })
        } else {
            selectbtn(button: btnAble1)
            if btnAble4.isSelected {
                deSelectbtn(button: btnAble4)
                hc_type.removeAll(where: { $0 == "4" })
            }
            hc_type.append("1")
        }
        isValidate()
    }
    
    @IBAction func able2Click(_ sender: UIButton) {
        if btnAble2.isSelected {
            deSelectbtn(button: btnAble2)
            hc_type.removeAll(where: { $0 == "2" })
        } else {
            selectbtn(button: btnAble2)
            if btnAble4.isSelected {
                deSelectbtn(button: btnAble4)
                hc_type.removeAll(where: { $0 == "4" })
            }
            hc_type.append("2")
        }
        isValidate()
    }
    
    @IBAction func able3Click(_ sender: UIButton) {
        if btnAble3.isSelected {
            deSelectbtn(button: btnAble3)
            hc_type.removeAll(where: { $0 == "3" })
        } else {
            selectbtn(button: btnAble3)
            if btnAble4.isSelected {
                deSelectbtn(button: btnAble4)
                hc_type.removeAll(where: { $0 == "4" })
            }
            hc_type.append("3")
        }
        isValidate()
    }
    
    @IBAction func able4Click(_ sender: UIButton) {
        if btnAble4.isSelected {
            deSelectbtn(button: btnAble4)
            hc_type.removeAll(where: { $0 == "4" })
        } else {
            selectbtn(button: btnAble4)
            deSelectbtn(button: btnAble1)
            deSelectbtn(button: btnAble2)
            deSelectbtn(button: btnAble3)
            hc_type.removeAll(where: { $0 == "1" })
            hc_type.removeAll(where: { $0 == "2" })
            hc_type.removeAll(where: { $0 == "3" })
            hc_type.append("4")
        }
        isValidate()
    }
    
    
    
    // #
    public func isValidate() -> Bool {
        
        if btnAble1.isSelected || btnAble2.isSelected || btnAble3.isSelected || btnAble4.isSelected {
            NotificationCenter.default.post(name: .joinNoti, object: true)
        } else {
            NotificationCenter.default.post(name: .joinNoti, object: false)
        }
        
        return true
    }
    
    public func deSelectbtn(button: UIButton) {
        button.isSelected = false
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.pretendard(type: .medium, size: 16)
    }
    
    public func selectbtn(button: UIButton) {
        button.isSelected = true
        button.backgroundColor = .primaryGreen100
        button.titleLabel?.font = UIFont.pretendard(type: .bold, size: 16)
    }
    // #
    public func getValue() -> [String] {
        return hc_type
    }
}
