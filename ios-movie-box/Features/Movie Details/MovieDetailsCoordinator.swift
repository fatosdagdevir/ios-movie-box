import Foundation

final class MovieDetailsCoordinator: Coordinating {
    struct Dependencies {
        let moviesProvider: MoviesProviding
        let movieDetailsViewStateFactory: MovieDetailsViewStateCreating
        let movieID: Int
    }
    
    weak var parent: Coordinating?
    var childCoordinators = [Coordinating]()
    var navigation: Navigating
    
    private let dependencies: Dependencies
    
    init(
        navigation: Navigating,
        parent: Coordinating,
        dependencies: Dependencies
    ) {
        self.navigation = navigation
        self.parent = parent
        self.dependencies = dependencies
    }
    
    func start() {
        let viewModel = MovieDetailsViewModel(
            movieID: dependencies.movieID,
            moviesProvider: dependencies.moviesProvider,
            movieDetailsViewStateFactory: dependencies.movieDetailsViewStateFactory
        )
        let view = MovieDetailsView(viewModel: viewModel).hosted()
        
        navigation.pushView(view, animated: true) {  [weak self] in
            guard let self else { return  }
            parent?.childDidFinish(self)
        }
    }
}
