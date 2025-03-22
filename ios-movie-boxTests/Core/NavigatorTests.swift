import XCTest
@testable import ios_movie_box

final class NavigatorTests: XCTestCase {
    private let navigationController = UINavigationController()
    private let viewController = UIViewController()
    private var sut: Navigator!
    
    override func setUp() {
        sut = Navigator(navigationController: navigationController)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_setViewControllers() {
        let viewController2 = UIViewController()

        sut.setViewControllers([viewController, viewController2], animated: false)
        
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigationController.viewControllers.first, viewController)
        XCTAssertEqual(navigationController.viewControllers.last, viewController2)
    }
    
    func test_pushView() {
        let expectation = self.expectation(description: "didFinish should be called")
        
        sut.pushView(viewController, animated: true) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(navigationController.viewControllers.first, viewController)
    }
    
    func test_pushView_withDefaultParameters() {
        let expectation = self.expectation(description: "didFinish should be called")
        
        sut.pushView(viewController, animated: true) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertEqual(navigationController.viewControllers.first, viewController)
    }
}
