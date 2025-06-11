import XCTest
@testable import ios_movie_box
import Combine

final class UpcomingMoviesViewModelTests: XCTestCase {
    private var sut: UpcomingMoviesViewModel!
    private var mockProvider: MockMoviesProvider!
    private var delegate: MockUpcomingMoviesViewModelDelegate!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        delegate = MockUpcomingMoviesViewModelDelegate()
        mockProvider = MockMoviesProvider()
        sut = UpcomingMoviesViewModel(moviesProvider: mockProvider)
        sut.delegate = delegate
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockProvider = nil
        delegate = nil
        cancellables = nil
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
            movies: UpcomingMovies.Movie.mockMovies(startingAt: 1, count: 20),
            totalPages: 3,
            totalResults: 60
        )
        
        await sut.loadMovies()
        
        XCTAssertEqual(mockProvider.fetchUpcomingMoviesCallCount, 1)
        XCTAssertEqual(mockProvider.capturedPage, 1)
        
        sut.loadMoreIfNeeded()
        
        try await Task.sleep(nanoseconds: 1_100_000_000) // needs to wait for throttle (1.1 seconds)
        XCTAssertEqual(mockProvider.fetchUpcomingMoviesCallCount, 2, "Should make second call after throttle")
        XCTAssertEqual(mockProvider.capturedPage, 2, "Should request page 2")
    }
    
    func test_pagination_flow() async throws {
        mockProvider.stubMoviesData = .init(
            page: 1,
            movies: UpcomingMovies.Movie.mockMovies(startingAt: 1, count: 20),
            totalPages: 3,
            totalResults: 60
        )
        
        await sut.loadMovies()
        
        if case .ready(let firstPageMovies) = sut.viewState {
            XCTAssertEqual(firstPageMovies.count, 20)
            XCTAssertTrue(sut.nextPageAvailable)
            
            mockProvider.stubMoviesData = .init(
                page: 2,
                movies: UpcomingMovies.Movie.mockMovies(startingAt: 21, count: 20), // to create unique id's
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
        
        XCTAssertEqual(mockProvider.fetchUpcomingMoviesCallCount, 2)
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
            movies: UpcomingMovies.Movie.mockMovies(startingAt: 1, count: 20),
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
        XCTAssertEqual(mockProvider.fetchUpcomingMoviesCallCount, 2, "Should only make one additional call due to throttling")
    }
    
    // MARK: - Search Tests
    func test_search_success() async {
        let searchResults = UpcomingMovies.Movie.mockMovies(startingAt: 1, count: 1)
        mockProvider.stubSearchData = .init(
            page: 1,
            movies: searchResults,
            totalPages: 1,
            totalResults: 1
        )
        
        await sut.searchMovies(query: "test")
        
        guard case .ready(let movies) = sut.viewState else {
            XCTFail("Expected ready state")
            return
        }
        
        XCTAssertEqual(movies, searchResults)
    }
    
    func test_search_debounce() async {
        sut.searchText = "t"
        sut.searchText = "te"
        sut.searchText = "tes"
        sut.searchText = "test"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        XCTAssertEqual(mockProvider.searchQueries.count, 1)
        XCTAssertEqual(mockProvider.searchQueries.first, "test")
    }
    
    func test_handleUpcomingMoviesResult_removesDuplicates() async {
        let upcomingMovies = [
            UpcomingMovies.Movie(id: 1, title: "Movie 1", overview: "", posterPath: "", releaseDate: ""),
            UpcomingMovies.Movie(id: 1, title: "Movie 2", overview: "", posterPath: "", releaseDate: ""), //Duplicate
            UpcomingMovies.Movie(id: 3, title: "Movie 3", overview: "", posterPath: "", releaseDate: "")
        ]
        mockProvider.stubMoviesData = .init(
            page: 1,
            movies: upcomingMovies,
            totalPages: 1,
            totalResults: 1
        )
        
        await sut.loadMovies()
        
        if case .ready(let movies) = sut.viewState {
            XCTAssertEqual(movies.count, 2)
            XCTAssertEqual(movies.first?.id, 1)
            XCTAssertEqual(movies.last?.id, 3)
        } else {
            XCTFail("Ready state with unique id's expected")
        }
    }
    
    func test_handleSearchedMoviesResult_removesDuplicates() async {
        let searchedMovies = [
            UpcomingMovies.Movie(id: 1, title: "Movie 1", overview: "", posterPath: "", releaseDate: ""),
            UpcomingMovies.Movie(id: 1, title: "Movie 2", overview: "", posterPath: "", releaseDate: ""), //Duplicate
            UpcomingMovies.Movie(id: 3, title: "Movie 3", overview: "", posterPath: "", releaseDate: "")
        ]
        mockProvider.stubSearchData = .init(
            page: 1,
            movies: searchedMovies,
            totalPages: 1,
            totalResults: 1
        )
        
        await sut.searchMovies(query: "test")
        
        if case .ready(let movies) = sut.viewState {
            XCTAssertEqual(movies.count, 2)
            XCTAssertEqual(movies.first?.id, 1)
            XCTAssertEqual(movies.last?.id, 3)
        } else {
            XCTFail("Ready state with unique id's expected")
        }
    }
    
    
    // MARK: - Navigation Tests
    func test_didRequestMovieDetail_callsDelegate() {
        sut.didSelect(movie: UpcomingMovies.Movie.mockMovie1)
        
        XCTAssertTrue(delegate.didRequestMovieDetailCalled)
        XCTAssertEqual(delegate.didRequestMovieDetailCallCount, 1)
    }
}
