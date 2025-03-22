import XCTest
@testable import ios_movie_box

final class MovieListViewModelTests: XCTestCase {
    private var sut: MovieListViewModel!
    private var delegate: MockMovieListViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        
        delegate = MockMovieListViewModelDelegate()
        sut = MovieListViewModel()
        sut.delegate = delegate
    }
    
    override func tearDown() {
        sut = nil
        delegate = nil
        super.tearDown()
    }
    
    func test_didRequestMovieDetail_callsDelegate() {
        sut.didRequestMovieDetail()
        
        XCTAssertTrue(delegate.didRequestMovieDetailCalled)
        XCTAssertEqual(delegate.didRequestMovieDetailCallCount, 1)
    }
}
