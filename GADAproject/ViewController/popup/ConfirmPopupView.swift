import UIKit


class ConfirmPopupView: UIViewController {

    public var cancelClick: (() -> ())?
    public var confirmClick: (() -> ())?
    
    public var descString:String!
    public var cancelString:String!
    public var confirmString:String!
    public var action:String!
    
    @IBOutlet weak var tvDesc: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        tvDesc.text = descString
        btnCancel.setTitle(cancelString, for: UIControl.State.normal)
        btnConfirm.setTitle(confirmString, for: UIControl.State.normal)
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        self.cancelClick!()
    }
    
    @IBAction func confirmClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        self.confirmClick!()
    }
    
}
