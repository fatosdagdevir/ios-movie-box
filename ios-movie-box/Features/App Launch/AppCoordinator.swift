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
        let moviesProvider = MoviesProvider()
        let dependencies = UpcomingMoviesCoordinator.Dependencies(
            moviesProvider: moviesProvider
        )
        let upcomingMoviesCoordinator = UpcomingMoviesCoordinator(
            dependencies: dependencies,
            navigation: navigation,
            parent: self
        )
        window.rootViewController = navigation.navigationController
        
        addChild(upcomingMoviesCoordinator)
        upcomingMoviesCoordinator.start()
    }
}
