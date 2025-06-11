import XCTest
@testable import ios_movie_box

final class MoviesProviderTests: XCTestCase {
    private var sut: MoviesProvider!
    private var mockNetwork: MockNetwork!
    
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetwork()
        sut = MoviesProvider(network: mockNetwork)
    }
    
    override func tearDown() {
        sut = nil
        mockNetwork = nil
        super.tearDown()
    }
    
    func test_fetchUpcomingMovies_success() async throws {
        let expectedPage =  1
        mockNetwork.mockData = try loadJSON(filename: "upcoming_movies")
        
        let result = try await sut.fetchUpcomingMovies(page: expectedPage)
        
        XCTAssertEqual(result.page, 1)
        XCTAssertEqual(result.totalPages, 10)
        XCTAssertEqual(result.totalResults, 100)
        XCTAssertEqual(result.movies.count, 2)
        
        let firstMovie = try XCTUnwrap(result.movies.first)
        XCTAssertEqual(firstMovie.id, 123)
        XCTAssertEqual(firstMovie.title, "The Dark Knight")
        XCTAssertEqual(firstMovie.overview, "When the menace known as the Joker wreaks havoc...")
        XCTAssertEqual(firstMovie.posterPath, "/poster.jpg")
    }
    
    func test_fetchMovieDetails_success() async throws {
        mockNetwork.mockData = try loadJSON(filename: "movie_details")
        
        let result = try await sut.fetchMovieDetails(id: 123)
        
        XCTAssertEqual(result.id, 123)
        XCTAssertEqual(result.title, "The Dark Knight")
        XCTAssertEqual(result.overview, "Test Overview")
        XCTAssertEqual(result.runtime, 152)
        XCTAssertEqual(result.voteAverage, 8.5)
        XCTAssertEqual(result.genres.count, 3)
        XCTAssertEqual(result.genres.first?.id, 28)
        XCTAssertEqual(result.genres.first?.name, "Action")
        XCTAssertEqual(result.originalLanguage, "en")
        XCTAssertEqual(result.backdropPath, "/backdrop.jpg")
        XCTAssertEqual(result.budget, 185000000)
        XCTAssertEqual(result.revenue, 1004558444)
        XCTAssertEqual(result.status, "Released")
        XCTAssertEqual(result.tagline, "Test Tagline")
    }
    
    func test_searchMovies_success() async throws {
        let expectedPage =  1
        mockNetwork.mockData = try loadJSON(filename: "searched_movies")
        
        let result = try await sut.searchMovies(query: "Dark", page: 1)
        
        XCTAssertEqual(result.page, 1)
        XCTAssertEqual(result.totalPages, 10)
        XCTAssertEqual(result.totalResults, 100)
        XCTAssertEqual(result.movies.count, 2)
        
        let firstMovie = try XCTUnwrap(result.movies.first)
        XCTAssertEqual(firstMovie.id, 123)
        XCTAssertEqual(firstMovie.title, "The Dark Knight")
        XCTAssertEqual(firstMovie.overview, "When the menace known as the Joker wreaks havoc...")
        XCTAssertEqual(firstMovie.posterPath, "/poster.jpg")
    }
    
    // MARK: - Error Tests
    func test_fetchUpcomingMovies_networkError() async {
        mockNetwork.mockError = NetworkError.offline
        
        do {
            _ = try await sut.fetchUpcomingMovies(page: 1)
            XCTFail("Expected error")
        } catch NetworkError.offline {
        } catch NetworkError.invalidStatus(let code) {
            XCTFail("Unexpected invalid status: \(code)")
        } catch MockNetwork.MockError.missingMockData {
            XCTFail("Unexpected missing mock data")
        } catch MockNetwork.MockError.invalidResponse {
            XCTFail("Unexpected invalid response")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_fetchMovieDetails_networkError() async {
        mockNetwork.mockError = NetworkError.invalidStatus(500)
        
        do {
            _ = try await sut.fetchMovieDetails(id: 123)
            XCTFail("Expected error")
        } catch NetworkError.offline {
            XCTFail("Unexpected offline error")
        } catch NetworkError.invalidStatus(let code) {
            XCTAssertEqual(code, 500)
        } catch MockNetwork.MockError.missingMockData {
            XCTFail("Unexpected missing mock data")
        } catch MockNetwork.MockError.invalidResponse {
            XCTFail("Unexpected invalid response")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    
    func test_fetchUpcomingMovies_missingMockData() async {
        mockNetwork.mockData = nil
        
        do {
            _ = try await sut.fetchUpcomingMovies(page: 1)
            XCTFail("Expected error")
        } catch NetworkError.offline {
            XCTFail("Unexpected offline error")
        } catch NetworkError.invalidStatus(let code) {
            XCTFail("Unexpected invalid status: \(code)")
        } catch MockNetwork.MockError.missingMockData {
        } catch MockNetwork.MockError.invalidResponse {
            XCTFail("Unexpected invalid response")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Helpers
    private func loadJSON(filename: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw MockNetwork.MockError.missingMockData
        }
        
        return try Data(contentsOf: url)
    }
}
