import Foundation

final class MovieListCoordinator: Coordinating {
    struct Dependencies {
        let movieListProvider: MoviesProviding
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
        navigation.setViewControllers([view], animated: false)
    }
}

extension MovieListCoordinator: MovieListViewModelDelegate {
    func didRequestMovieDetail(_ movieID: Int) {
        let movieDetailsViewStateFactory = MovieDetailsViewStateFactory()
        let dependencies = MovieDetailsCoordinator.Dependencies(
            movieListProvider: dependencies.movieListProvider,
            movieDetailsViewStateFactory: movieDetailsViewStateFactory,
            movieID: movieID)
        
        let moviewDetailsCoordinator = MovieDetailsCoordinator(
            navigation: navigation,
            parent: self,
            dependencies: dependencies
        )
        addChild(moviewDetailsCoordinator)
        moviewDetailsCoordinator.start()
    }
}
