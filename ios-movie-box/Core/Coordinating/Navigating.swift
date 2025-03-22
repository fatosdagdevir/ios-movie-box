import UIKit

protocol Navigating: AnyObject {
    var navigationController: UINavigationController { get }

    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
    
    func pushView(_ viewController: UIViewController, animated: Bool, didFinish: (() -> Void)?)
}
