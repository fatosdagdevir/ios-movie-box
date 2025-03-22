@testable import ios_movie_box
import UIKit

class MockNavigator: Navigating {
    var navigationController = UINavigationController()
    
    var didSetViewControllers = false
    var spySetViewControllers = [UIViewController]()
    var didPushView = false
    
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        didSetViewControllers = true
        spySetViewControllers = viewControllers
    }
    
    func pushView(_ viewController: UIViewController, animated: Bool, didFinish: (() -> Void)?) {
        spySetViewControllers.append(viewController)
        didPushView = true
    }
}
