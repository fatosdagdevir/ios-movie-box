import XCTest
@testable import ios_movie_box

final class MovieDetailsViewStateFactoryTests: XCTestCase {
    private var sut: MovieDetailsViewStateFactory!
    
    override func setUp() {
        super.setUp()
        sut = MovieDetailsViewStateFactory()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_genreList_withMultipleGenres_joinsWithComma() {
        let movie = stubMovieDetails(
            genres: [
                .init(id: 1, name: "Action"),
                .init(id: 2, name: "Drama"),
                .init(id: 3, name: "Crime")
            ]
        )
        
        guard case .ready(let displayData) = sut.viewState(for: movie) else {
            XCTFail("Expected ready state")
            return
        }
        
        XCTAssertEqual(displayData.genreList, "Action, Drama, Crime")
    }
    
    func test_genreList_withSingleGenre_hasNoComma() {
        let movie = stubMovieDetails(
            genres: [.init(id: 1, name: "Action")]
        )
        
        guard case .ready(let displayData) = sut.viewState(for: movie) else {
            XCTFail("Expected ready state")
            return
        }
        
        XCTAssertEqual(displayData.genreList, "Action")
    }
    
    func test_imageURL_withValidBackdropPath_returnsURL() {
        let backdropPath = "/test-path.jpg"
        let movie = stubMovieDetails(
            backdropPath: backdropPath
        )
        
        guard case .ready(let displayData) = sut.viewState(for: movie) else {
            XCTFail("Expected ready state")
            return
        }
        
        XCTAssertNotNil(displayData.imageURL)
        XCTAssertEqual(
            displayData.imageURL?.absoluteString,
            ImageConfig.backdropURL(path: backdropPath)?.absoluteString
        )
    }
    
    
    func test_rating_formatsWithOneDecimalPlace() {
        let movie = stubMovieDetails(
            voteAverage: 8.567
        )
        
        guard case .ready(let displayData) = sut.viewState(for: movie) else {
            XCTFail("Expected ready state")
            return
        }
        
        XCTAssertEqual(displayData.rating, "Rating: 8.6")
    }
    
    // MARK: Helpers
    private func stubMovieDetails(
        id: Int = 1,
        title: String = "Test Movie",
        overview: String = "Test Overview",
        runtime: Int = 120,
        voteAverage: Double = 8.0,
        genres: [MovieDetails.Genre] = [],
        originalLanguage: String = "en",
        backdropPath: String? = "/test-path.jpg",
        budget: Int = 1000000,
        revenue: Int = 2000000,
        status: String = "Released",
        tagline: String? = "Test Tagline"
    ) -> MovieDetails {
        .init(
            id: id,
            title: title,
            overview: overview,
            runtime: runtime,
            voteAverage: voteAverage,
            genres: genres,
            originalLanguage: originalLanguage,
            backdropPath: backdropPath,
            budget: budget,
            revenue: revenue,
            status: status,
            tagline: tagline
        )
    }
}
