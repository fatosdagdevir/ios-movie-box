@testable import ios_movie_box

class MockMoviesProvider: MoviesProviding {
    var stubMoviesData: UpcomingMovies
    var stubMovieDetails: MovieDetails
    var stubSearchData: UpcomingMovies
    var stubError: Error?
    var capturedPage: Int?
    var fetchUpcomingMoviesCallCount = 0
    var fetchMovieDetailsCallCount = 0
    var searchMoviesCallCount = 0
    var searchQueries: [String] = []
    var capturedMovieID: Int?
    
    init(
        stubMoviesData: UpcomingMovies = .mock,
        stubMovieDetails: MovieDetails = .mock,
        stubSearchData: UpcomingMovies = .mock
    ) {
        self.stubMoviesData = stubMoviesData
        self.stubMovieDetails = stubMovieDetails
        self.stubSearchData = stubSearchData
    }
    
    func fetchUpcomingMovies(page: Int) async throws -> ios_movie_box.UpcomingMovies {
        fetchUpcomingMoviesCallCount += 1
        capturedPage = page
        
        if let stubError = stubError {
            throw stubError
        }
        
        return stubMoviesData
    }
    
    func fetchMovieDetails(id: Int) async throws -> ios_movie_box.MovieDetails {
        fetchMovieDetailsCallCount += 1
        capturedMovieID = id
        if let stubError = stubError {
            throw stubError
        }
        
        return stubMovieDetails
    }
    
    func searchMovies(query: String, page: Int) async throws -> ios_movie_box.UpcomingMovies {
        searchMoviesCallCount += 1
        searchQueries.append(query)
        
        if let stubError = stubError {
            throw stubError
        }
        
        return stubSearchData
    }
}

// MARK: - Mock Data
extension UpcomingMovies {
    static var mock: UpcomingMovies {
        .init(
            page: 1,
            movies: [
                .mockMovie1,
                .mockMovie2,
                .mockMovie3
            ],
            totalPages: 3,
            totalResults: 60
        )
    }
    
    static var emptyMock: UpcomingMovies {
        .init(
            page: 1,
            movies: [],
            totalPages: 0,
            totalResults: 0
        )
    }
}

// MARK: - Mock Movie Data
extension UpcomingMovies.Movie {
    static let mockMovie1 = UpcomingMovies.Movie(
        id: 1,
        title: "The Dark Knight",
        overview: "Batman raises the stakes in his war on crime.",
        posterPath: "/dark-knight-poster.jpg",
        releaseDate: "2008-07-18"
    )
    
    static let mockMovie2 = UpcomingMovies.Movie(
        id: 2,
        title: "Inception",
        overview: "A thief who steals corporate secrets through dream-sharing technology.",
        posterPath: "/inception-poster.jpg",
        releaseDate: "2010-07-16"
    )
    
    static let mockMovie3 = UpcomingMovies.Movie(
        id: 3,
        title: "Interstellar",
        overview: "A team of explorers travel through a wormhole in space.",
        posterPath: "/interstellar-poster.jpg",
        releaseDate: "2014-11-07"
    )
    
    static func mockMovies(startingAt index: Int, count: Int) -> [UpcomingMovies.Movie] {
        (index...(index+count)-1).map { index in
            UpcomingMovies.Movie(
                id: index,
                title: "Movie \(index)",
                overview: "Overview for movie \(index)",
                posterPath: "/movie-\(index)-poster.jpg",
                releaseDate: "2024-\(String(format: "%02d", index))-01"
            )
        }
    }
}

// MARK: - Mock Movie Details
extension MovieDetails {
    static var mock: MovieDetails {
        .init(
            id: 1,
            title: "The Dark Knight",
            overview: "Batman raises the stakes in his war on crime.",
            runtime: 152,
            voteAverage: 8.5,
            genres: [
                .init(id: 1, name: "Action"),
                .init(id: 2, name: "Drama")
            ],
            originalLanguage: "en",
            backdropPath: "/dark-knight-backdrop.jpg",
            budget: 185000000,
            revenue: 1004558444,
            status: "Released",
            tagline: "Why So Serious?"
        )
    }
}
