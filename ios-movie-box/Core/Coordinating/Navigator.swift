import UIKit

class Navigator: Navigating {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        navigationController.setViewControllers(viewControllers, animated: animated)
    }

    func pushView(_ viewController: UIViewController, animated: Bool, didFinish: (() -> Void)?) {
        navigationController.pushViewController(viewController, animated: animated)
        didFinish?()
    }
}
