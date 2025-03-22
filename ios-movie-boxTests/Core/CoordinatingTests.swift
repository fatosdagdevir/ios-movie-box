import XCTest
@testable import ios_movie_box

final class CoordinatingTests: XCTestCase {
    private var sut: Coordinating!
    
    override func setUp() {
        sut = MockCoordinator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_addChild_appendsChild_withDuplicates() {
        let child1 = MockCoordinator()
        let child2 = MockCoordinator()
        
        sut.addChild(child1)
        XCTAssertEqual(sut.childCoordinators.count, 1)
        
        sut.addChild(child2, removeDuplicates: true)
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.last === child2 )
    }
    
    func test_addChild_appendsChild_withoutDuplicates() {
        let child1 = MockCoordinator()
        let child2 = MockCoordinator()
        
        sut.addChild(child1)
        XCTAssertEqual(sut.childCoordinators.count, 1)
        
        sut.addChild(child2)
        XCTAssertEqual(sut.childCoordinators.count, 2)
        XCTAssertTrue(sut.childCoordinators.first === child1 )
        XCTAssertTrue(sut.childCoordinators.last === child2 )
    }
    
    func test_removeChild() {
        let child1 = MockCoordinator()
        
        sut.addChild(child1)
        sut.removeChild(child1)
        XCTAssertEqual(sut.childCoordinators.count, 0)
        XCTAssertFalse(sut.childCoordinators.contains { $0 === child1 })
    }
    
    func test_childDidFinish() {
        let child1 = MockCoordinator()
        
        sut.addChild(child1)
        sut.childDidFinish(child1)
        XCTAssertEqual(sut.childCoordinators.count, 0)
        XCTAssertFalse(sut.childCoordinators.contains { $0 === child1 })
    }
}
