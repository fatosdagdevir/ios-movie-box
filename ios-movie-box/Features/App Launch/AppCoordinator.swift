import Foundation
import UIKit

final class AppCoordinator: Coordinating {
    weak var parent: Coordinating?
    var childCoordinators: [Coordinating] = []
    
    var window: UIWindow
    var navigation: Navigating
    
    init(window: UIWindow, navigation: Navigating) {
        self.window = window
        self.navigation = navigation
    }
    
    func start() {
        let movieListProvider = MoviesProvider()
        let dependencies = MovieListCoordinator.Dependencies(
            movieListProvider: movieListProvider
        )
        let movieListCoordinator = MovieListCoordinator(
            dependencies: dependencies,
            navigation: navigation,
            parent: self
        )
        window.rootViewController = navigation.navigationController
        
        addChild(movieListCoordinator)
        movieListCoordinator.start()
    }
}
