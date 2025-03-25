import Foundation

final class MovieDetailsCoordinator: Coordinating {
    weak var parent: Coordinating?
    var childCoordinators = [Coordinating]()
    
    var navigation: Navigating
    
    init(navigation: Navigating, parent: Coordinating) {
        self.navigation = navigation
        self.parent = parent
    }
    
    func start() {
        let viewModel = MovieDetailsViewModel()
        let view = MovieDetailsView(viewModel: viewModel).hosted()
        navigation.pushView(view, animated: true, didFinish: nil)
    }
}
