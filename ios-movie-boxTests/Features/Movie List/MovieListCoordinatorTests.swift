import XCTest
@testable import ios_movie_box

final class MovieListCoordinatorTests: XCTestCase {
    private var sut: MovieListCoordinator!
    private var navigation: MockNavigator!
    private var parent: MockCoordinator!
    
    override func setUp() {
        navigation = .init()
        parent = .init()
        sut = MovieListCoordinator(
            dependencies: .init(movieListProvider: MockMovieListProvider()),
            navigation: navigation,
            parent: parent
        )
    }
    
    override func tearDown() {
        sut = nil
        navigation = nil
        parent = nil
        super.tearDown()
    }
    
    func test_init() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.childCoordinators.count, 0)
        XCTAssertNotNil(sut.navigation)
        XCTAssertTrue(sut.navigation is MockNavigator)
        XCTAssertTrue(sut.parent === parent)
    }
    
    func test_start() {
        sut.start()
        
        XCTAssertEqual(navigation.spySetViewControllers.count, 1)
        XCTAssertNotNil(navigation.spySetViewControllers.first?.asHosted(MovieListView.self))
    }
    
    func test_didRequestMovieDetail_createsAndStartsMovieDetailsCoordinator() {
        sut.didRequestMovieDetail()
        
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.first is MovieDetailsCoordinator)
    }
    
    func test_didRequestMovieDetail_setsCorrectParentAndNavigation() {
        sut.didRequestMovieDetail()
        
        guard let movieDetailsCoordinator = sut.childCoordinators.first as? MovieDetailsCoordinator else {
            XCTFail("Expected MoviewDetailsCoordinator")
            return
        }
        
        XCTAssertTrue(movieDetailsCoordinator.parent === sut)
        XCTAssertTrue(movieDetailsCoordinator.navigation === navigation)
    }
    
    func test_removeChild_afterMovieDetail() {
        sut.didRequestMovieDetail()
        let child = sut.childCoordinators.first
        
        sut.removeChild(child!)
        
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
}
