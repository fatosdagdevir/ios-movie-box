import Foundation

final class MovieListCoordinator: Coordinating {
    struct Dependencies {
        let movieListProvider: MovieListProviding
    }
    
    weak var parent: Coordinating?
    var childCoordinators = [Coordinating]()
    var navigation: Navigating
    
    private let dependencies: Dependencies
    
    init(
        dependencies: Dependencies,
        navigation: Navigating,
        parent: Coordinating
    ) {
        self.dependencies = dependencies
        self.navigation = navigation
        self.parent = parent
    }
    
    func start() {
        let viewModel = MovieListViewModel(
            movieListProvider: dependencies.movieListProvider
        )
        viewModel.delegate = self
        let view = MovieListView(viewModel: viewModel).hosted()
        
        // Hide back button before pushing
        navigation.navigationController.navigationItem.hidesBackButton = true
        
        navigation.setViewControllers([view], animated: false)
    }
}

extension MovieListCoordinator: MovieListViewModelDelegate {
    func didRequestMovieDetail(_ movieID: Int) {
        let moviewDetailsCoordinator = MovieDetailsCoordinator(navigation: navigation, parent: self)
        addChild(moviewDetailsCoordinator)
        moviewDetailsCoordinator.start()
    }
}
