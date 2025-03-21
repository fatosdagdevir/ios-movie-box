import Foundation

final class MovieListCoordinator: Coordinating {
    weak var parent: Coordinating?
    var childCoordinators = [Coordinating]()
    
    var navigation: Navigating
    
    init(navigation: Navigating, parent: Coordinating) {
        self.navigation = navigation
        self.parent = parent
    }
    
    func start() {
        let viewModel = MovieListViewModel()
        viewModel.delegate = self
        let view = MovieListView(viewModel: viewModel).hosted()
        
        navigation.setViewControllers([view], animated: false)
    }
}

extension MovieListCoordinator: MovieListViewModelDelegate {
    func didRequestMovieDetail() {
        let moviewDetailsCoordinator = MoviewDetailsCoordinator(navigation: navigation, parent: self)
        addChild(moviewDetailsCoordinator)
        moviewDetailsCoordinator.start()
    }
}
