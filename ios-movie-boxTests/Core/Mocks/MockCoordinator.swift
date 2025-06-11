@testable import ios_movie_box

class MockCoordinator: Coordinating {
    weak var parent: Coordinating?
    var childCoordinators = [Coordinating]()
    
    func start() { }
}
