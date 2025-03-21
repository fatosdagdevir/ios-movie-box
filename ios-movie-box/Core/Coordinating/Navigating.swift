import UIKit

protocol Navigating {
    var navigationController: UINavigationController { get }

    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
    
    func pushView(_ viewController: UIViewController, animated: Bool, didFinish: (() -> Void)?)
}

extension Navigating {
    func pushView(_ viewController: UIViewController, animated: Bool = true, didFinish: (() -> Void)? = nil) {
        pushView(viewController, animated: animated, didFinish: didFinish)
    }
}
