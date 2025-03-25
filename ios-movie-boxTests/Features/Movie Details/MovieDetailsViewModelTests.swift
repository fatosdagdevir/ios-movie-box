import XCTest
@testable import ios_movie_box

final class MovieDetailsViewModelTests: XCTestCase {
    private var sut: MovieDetailsViewModel!
    private var mockProvider: MockMoviesProvider!
    private var mockViewStateFactory: MockMovieDetailsViewStateFactory!
    
    override func setUp() {
        super.setUp()
        mockProvider = MockMoviesProvider()
        mockViewStateFactory = MockMovieDetailsViewStateFactory()
        sut = MovieDetailsViewModel(
            movieID: 1,
            moviesProvider: mockProvider,
            movieDetailsViewStateFactory: mockViewStateFactory
        )
    }
    
    override func tearDown() {
        sut = nil
        mockProvider = nil
        mockViewStateFactory = nil
        super.tearDown()
    }
    
    func test_loadMovieDetails_success_updatesViewState() async {
        let expectedMovie = MovieDetails.mock
        let expectedViewState = MovieDetailsView.ViewState.ready(displayData: .mockDisplayData)
        mockProvider.stubMovieDetails = expectedMovie
        mockViewStateFactory.stubbedViewState = expectedViewState
        
        await sut.loadMovieDetails()
        
        XCTAssertEqual(mockProvider.fetchMovieDetailsCallCount, 1)
        XCTAssertEqual(mockProvider.capturedMovieID, 1)
        XCTAssertEqual(mockViewStateFactory.viewStateCallCount, 1)
        XCTAssertEqual(sut.viewState, .ready(displayData: .mockDisplayData))
    }
    
    func test_loadMovieDetails_failure_updatesViewStateWithError() async {
        let expectedError = NetworkError.invalidStatus(500)
        mockProvider.stubError = expectedError
        
        await sut.loadMovieDetails()
        
        guard case .error(let errorViewModel) = sut.viewState else {
            XCTFail("Expected error state")
            return
        }
        XCTAssertEqual(errorViewModel.headerText, "Oops!")
        XCTAssertEqual(mockProvider.fetchMovieDetailsCallCount, 1)
    }
    
    func test_refresh_setsLoadingState_thenLoadsDetails() async {
        let expectedMovie = MovieDetails.mock
        let expectedViewState = MovieDetailsView.ViewState.ready(displayData: .mockDisplayData)
        mockProvider.stubMovieDetails = expectedMovie
        mockViewStateFactory.stubbedViewState = expectedViewState
        
        await sut.refresh()
        
        XCTAssertEqual(mockProvider.fetchMovieDetailsCallCount, 1)
        XCTAssertEqual(sut.viewState, expectedViewState)
    }
    
    func test_refresh_whenError_showsErrorState() async {
        mockProvider.stubError = NetworkError.offline
        
        await sut.refresh()
        
        guard case .error(let errorViewModel) = sut.viewState else {
            XCTFail("Expected error state")
            return
        }
        XCTAssertTrue(errorViewModel.error is NetworkError)
        XCTAssertEqual(errorViewModel.headerText, "You are offline!")
    }
    
    func test_errorViewModel_hasRefreshAction() async {
        mockProvider.stubError = NetworkError.offline
        
        await sut.loadMovieDetails()
        
        guard case .error(let errorViewModel) = sut.viewState else {
            XCTFail("Expected error state")
            return
        }
        
        mockProvider.stubError = nil
        mockProvider.stubMovieDetails = .mock
        await errorViewModel.action()
        
        XCTAssertEqual(mockProvider.fetchMovieDetailsCallCount, 2)
    }
}
