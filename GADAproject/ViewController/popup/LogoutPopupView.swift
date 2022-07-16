import UIKit


class LogoutPopupView: UIViewController {

    
    @IBOutlet weak var tvTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func confirmClick(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
}
