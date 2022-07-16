import UIKit


class NavigationController: UINavigationController {

    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }

    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
       return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    static func createFromNib<T: UIViewController>(storyBoardId: String) -> T?{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyBoardId) as? T
    }
    
    override var shouldAutorotate: Bool {
        return (visibleViewController?.shouldAutorotate)!
    }

    /*
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (visibleViewController?.supportedInterfaceOrientations)!
    }
    */
}
