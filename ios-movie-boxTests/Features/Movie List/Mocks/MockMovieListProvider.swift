@testable import ios_movie_box

final class MockMovieListProvider: MovieListProviding {
    var stubMockData: UpcomingMoviesData
    var stubError: Error?
    var capturedPage: Int?
    var callCount = 0
    
    init(stubMockData: UpcomingMoviesData = .mock) {
        self.stubMockData = stubMockData
    }
    
    func fetchUpcomingMovies(page: Int) async throws -> ios_movie_box.UpcomingMoviesData {
        callCount += 1
        capturedPage = page
        
        if let stubError = stubError {
            throw stubError
        }
        
        return stubMockData
    }
}

// MARK: - Mock Data
extension UpcomingMoviesData {
    static var mock: UpcomingMoviesData {
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
    
    static var emptyMock: UpcomingMoviesData {
        .init(
            page: 1,
            movies: [],
            totalPages: 0,
            totalResults: 0
        )
    }
    
    static var singlePageMock: UpcomingMoviesData {
        .init(
            page: 1,
            movies: [.mockMovie1],
            totalPages: 1,
            totalResults: 1
        )
    }
    static var lastPageMock: UpcomingMoviesData {
        .init(
            page: 3,
            movies: [.mockMovie3],
            totalPages: 3,
            totalResults: 55
        )
    }
}

// MARK: - Mock Movie Data
extension UpcomingMoviesData.Movie {
    static let mockMovie1 = UpcomingMoviesData.Movie(
        title: "The Dark Knight",
        overview: "Batman raises the stakes in his war on crime.",
        posterPath: "/dark-knight-poster.jpg",
        releaseDate: "2008-07-18"
    )
    
    static let mockMovie2 = UpcomingMoviesData.Movie(
        title: "Inception",
        overview: "A thief who steals corporate secrets through dream-sharing technology.",
        posterPath: "/inception-poster.jpg",
        releaseDate: "2010-07-16"
    )
    
    static let mockMovie3 = UpcomingMoviesData.Movie(
        title: "Interstellar",
        overview: "A team of explorers travel through a wormhole in space.",
        posterPath: "/interstellar-poster.jpg",
        releaseDate: "2014-11-07"
    )
    
    static func mockMovies(count: Int) -> [UpcomingMoviesData.Movie] {
        (1...count).map { index in
            UpcomingMoviesData.Movie(
                title: "Movie \(index)",
                overview: "Overview for movie \(index)",
                posterPath: "/movie-\(index)-poster.jpg",
                releaseDate: "2024-\(String(format: "%02d", index))-01"
            )
        }
    }
}
