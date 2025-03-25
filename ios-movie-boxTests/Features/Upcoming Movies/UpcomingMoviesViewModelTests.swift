import XCTest
@testable import ios_movie_box

final class UpcomingMoviesViewModelTests: XCTestCase {
    private var sut: UpcomingMoviesViewModel!
    private var mockProvider: MockMoviesProvider!
    private var delegate: MockUpcomingMoviesViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        
        delegate = MockUpcomingMoviesViewModelDelegate()
        mockProvider = MockMoviesProvider()
        sut = UpcomingMoviesViewModel(moviesProvider: mockProvider)
        sut.delegate = delegate
    }
    
    override func tearDown() {
        sut = nil
        mockProvider = nil
        delegate = nil
        super.tearDown()
    }
    
    func test_init_isLoading() {
        if case .loading = sut.viewState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Loading state expected")
        }
    }
    
    // MARK: - Load Movies Tests
    func test_loadMovies_success() async {
        mockProvider.stubMoviesData = .mock
        
        await sut.loadMovies()
        
        if case .ready(let movies) = sut.viewState {
            XCTAssertEqual(movies.count, 3)
            XCTAssertEqual(movies[0].title, "The Dark Knight")
            XCTAssertEqual(movies[1].title, "Inception")
            XCTAssertEqual(movies[2].title, "Interstellar")
        } else {
            XCTFail("Ready state expected")
        }
    }
    
    func test_loadMovies_empty() async {
        mockProvider.stubMoviesData = .emptyMock
        
        await sut.loadMovies()
        
        if case .ready(let movies) = sut.viewState {
            XCTAssertTrue(movies.isEmpty)
            XCTAssertFalse(sut.nextPageAvailable)
        } else {
            XCTFail("Ready state with empty data expected")
        }
    }
    
    func test_loadMovies_error() async {
        mockProvider.stubError = NetworkError.offline
        
        await sut.loadMovies()
        
        if case .error(let viewModel) = sut.viewState {
            XCTAssertTrue(viewModel.error is NetworkError)
            XCTAssertEqual(viewModel.headerText, "You are offline!")
        } else {
            XCTFail("Error state expected")
        }
    }
    
    // MARK: - Pagination Tests
    func test_loadMoreIfNeeded_callsProvider() async throws {
        mockProvider.stubMoviesData = .init(
            page: 1,
            movies: UpcomingMovies.Movie.mockMovies(count: 20),
            totalPages: 3,
            totalResults: 60
        )
        
        await sut.loadMovies()
        
        XCTAssertEqual(mockProvider.callCount, 1)
        XCTAssertEqual(mockProvider.capturedPage, 1)
        
        sut.loadMoreIfNeeded()
        
        try await Task.sleep(nanoseconds: 1_100_000_000) // needs to wait for throttle (1.1 seconds)
        XCTAssertEqual(mockProvider.callCount, 2, "Should make second call after throttle")
        XCTAssertEqual(mockProvider.capturedPage, 2, "Should request page 2")
    }
    
    func test_pagination_flow() async throws {
        mockProvider.stubMoviesData = .init(
            page: 1,
            movies: UpcomingMovies.Movie.mockMovies(count: 20),
            totalPages: 3,
            totalResults: 60
        )
        
        await sut.loadMovies()
        
        if case .ready(let firstPageMovies) = sut.viewState {
            XCTAssertEqual(firstPageMovies.count, 20)
            XCTAssertTrue(sut.nextPageAvailable)
            
            mockProvider.stubMoviesData = .init(
                page: 2,
                movies: UpcomingMovies.Movie.mockMovies(count: 20),
                totalPages: 3,
                totalResults: 60
            )
            
            sut.loadMoreIfNeeded()
            
            try await Task.sleep(nanoseconds: 1_100_000_000)
            
            if case .ready(let allMovies) = sut.viewState {
                XCTAssertEqual(allMovies.count, 40, "Should have movies from both pages (2 * 20 = 40)")
                XCTAssertTrue(sut.nextPageAvailable, "Should have one more page available")
            } else {
                XCTFail("Ready state expected")
            }
        } else {
            XCTFail("Ready state expected")
        }
    }
    
    // MARK: - Refresh Tests
    func test_refresh_resetsStateAndReloads() async {
        mockProvider.stubMoviesData = .mock
        await sut.loadMovies()
        
        await sut.refresh()
        
        XCTAssertEqual(mockProvider.callCount, 2)
        XCTAssertEqual(mockProvider.capturedPage, 1)
    }
    
    func test_refresh_callsLoadMovies() async {
        mockProvider.stubError = NetworkError.offline
        await sut.loadMovies()
        
        mockProvider.stubError = nil
        mockProvider.stubMoviesData = .mock
        await sut.refresh()
        
        if case .ready(let movies) = sut.viewState {
            XCTAssertFalse(movies.isEmpty)
        } else {
            XCTFail("Ready state after refresh expected")
        }
    }
    
    // MARK: - Throttle Test
    func test_loadMoreIfNeeded_throttling() async throws {
        mockProvider.stubMoviesData = .init(
            page: 1,
            movies: UpcomingMovies.Movie.mockMovies(count: 20),
            totalPages: 3,
            totalResults: 60
        )
        
        await sut.loadMovies()
        
        // When - Rapidly make calls
        sut.loadMoreIfNeeded()
        sut.loadMoreIfNeeded()
        sut.loadMoreIfNeeded()
        
        // Then - Wait for throttle and verify only one additional call was made
        try await Task.sleep(nanoseconds: 1_100_000_000)
        XCTAssertEqual(mockProvider.callCount, 2, "Should only make one additional call due to throttling")
    }
    
    // MARK: - Navigation Tests
    func test_didRequestMovieDetail_callsDelegate() {
        sut.didSelect(movie: UpcomingMovies.Movie.mockMovie1)
        
        XCTAssertTrue(delegate.didRequestMovieDetailCalled)
        XCTAssertEqual(delegate.didRequestMovieDetailCallCount, 1)
    }
}
