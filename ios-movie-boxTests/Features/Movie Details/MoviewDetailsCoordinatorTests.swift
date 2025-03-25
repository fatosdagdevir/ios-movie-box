import XCTest
@testable import ios_movie_box

final class MoviewDetailsCoordinatorTests: XCTestCase {
    private var sut: MovieDetailsCoordinator!
    private var navigation: MockNavigator!
    private var parent: MockCoordinator!
    
    override func setUp() {
        super.setUp()
        navigation = MockNavigator()
        parent = MockCoordinator()
        let dependencies = MovieDetailsCoordinator.Dependencies(
            moviesProvider: MockMoviesProvider(),
            movieDetailsViewStateFactory: MockMovieDetailsViewStateFactory(),
            movieID: 3
        )
        sut = MovieDetailsCoordinator(
            navigation: navigation,
            parent: parent,
            dependencies: dependencies
        )
    }
    
    override func tearDown() {
        sut = nil
        navigation = nil
        parent = nil
        super.tearDown()
    }
    
    func test_init() {
        XCTAssertEqual(sut.childCoordinators.count, 0)
        XCTAssertIdentical(sut.navigation, navigation)
        XCTAssertIdentical(sut.parent, parent)
    }
    
    func test_start_pushesCorrectView() {
        sut.start()
        
        XCTAssertEqual(navigation.spySetViewControllers.count, 1)
        XCTAssertNotNil(navigation.spySetViewControllers.first?.asHosted(MovieDetailsView.self))
        XCTAssertTrue(navigation.didPushView)
    }
}
