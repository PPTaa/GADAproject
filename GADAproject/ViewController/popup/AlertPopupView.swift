import UIKit


class AlertPopupView: UIViewController {

    public var confirmClick: (() -> ())?
    
    public var descString:String!
    public var confirmString:String!
    public var action:String!
    
//    @IBOutlet weak var tvDesc: UILabel!
//    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var tvDesc: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        tvDesc.text = descString
        btnConfirm.setTitle(confirmString, for: UIControl.State.normal)
    }
    
    @IBAction func confirmClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        self.confirmClick!()
    }
    
}
