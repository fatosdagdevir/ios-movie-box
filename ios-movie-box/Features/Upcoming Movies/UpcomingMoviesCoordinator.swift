import Foundation

final class UpcomingMoviesCoordinator: Coordinating {
    struct Dependencies {
        let moviesProvider: MoviesProviding
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
        let viewModel = UpcomingMoviesViewModel(
            moviesProvider: dependencies.moviesProvider
        )
        viewModel.delegate = self
        let view = UpcomingMoviesView(viewModel: viewModel).hosted()
        navigation.setViewControllers([view], animated: false)
    }
}

extension UpcomingMoviesCoordinator: UpcomingMoviesViewModelDelegate {
    func didRequestMovieDetail(_ movieID: Int) {
        let movieDetailsViewStateFactory = MovieDetailsViewStateFactory()
        let dependencies = MovieDetailsCoordinator.Dependencies(
            moviesProvider: dependencies.moviesProvider,
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
