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
        viewModel.delegate = self
        let view = MovieDetailsView(viewModel: viewModel).hosted()
        
        // Hide back button before pushing
        navigation.navigationController.navigationItem.hidesBackButton = true
        
        navigation.pushView(view, animated: true, didFinish: nil)
    }
}

extension MovieDetailsCoordinator: MovieDetailsViewModelDelegate {
    func dismiss() {
        navigation.popBack(animated: true) { [weak self] in
            guard let self else { return }
            self.parent?.childDidFinish(self)
        }
    }
}
