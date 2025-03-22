import Foundation

final class MoviewDetailsCoordinator: Coordinating {
    weak var parent: Coordinating?
    var childCoordinators = [Coordinating]()
    
    var navigation: Navigating
    
    init(navigation: Navigating, parent: Coordinating) {
        self.navigation = navigation
        self.parent = parent
    }
    
    func start() {
        let view = MoviewDetailsView().hosted()
        navigation.pushView(view, animated: true, didFinish: nil)
    }
}
