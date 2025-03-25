import XCTest
@testable import ios_movie_box

final class AppCoordinatorTests: XCTestCase {
    private var sut: AppCoordinator!
    private var window: UIWindow!
    private var navigator: Navigating!
    
    override func setUp() {
        window = UIWindow()
        navigator = MockNavigator()
        sut = AppCoordinator(window: window, navigation: navigator)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_appCoordinator_init() {
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.window)
        XCTAssertNotNil(sut.navigation)
        XCTAssertEqual(sut.childCoordinators.count, 0)
        XCTAssertNil(sut.parent)
    }
    
    func test_appCoordinator_start() {
        sut.start()
        
        XCTAssertNotNil(window.rootViewController)
        XCTAssertEqual(window.rootViewController, navigator.navigationController)
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.first is MovieListCoordinator)
    }
}
