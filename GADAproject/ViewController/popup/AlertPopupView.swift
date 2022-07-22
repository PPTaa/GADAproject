import UIKit


class AlertPopupView: UIViewController {

    public var confirmClick: (() -> ())?
    
    @IBOutlet weak var popupView: UIView!
    
    public var descString:String!
    public var contentString:String!
    public var confirmString:String!
    public var action:String!
    
    
    @IBOutlet weak var tvDesc: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.roundCorner(radius: 10)
     
        tvDesc.text = descString
        tvContent.text = contentString
        btnConfirm.setTitle(confirmString, for: UIControl.State.normal)
    }
    
    @IBAction func confirmClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        self.confirmClick!()
    }
    
}
