import Foundation

protocol MoviesProviding {
    func fetchUpcomingMovies(page: Int) async throws -> UpcomingMovies
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
}

final class MoviesProvider: MoviesProviding {
    private let network: Networking
    init(network: Networking = Network()) {
        self.network = network
    }
    
    func fetchUpcomingMovies(page: Int) async throws -> UpcomingMovies {
        let endpoint = UpcomingMoviesEndpoint(page: page)
        let request = UpcomingMoviesRequest(endpoint: endpoint)
        let response = try await network.send(request: request)
        return response.mapped
    }
    
    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let endpoint = MovieDetailsEndpoint(movieID: id)
        let request = MovieDetailsRequest(endpoint: endpoint)
        let response = try await network.send(request: request)
        return response.mapped
    }
}

// MARK: - Fetch Upcoming Movie List
private struct UpcomingMoviesEndpoint: EndpointProtocol {
    let base = Constants.apiBase
    let path = "3/movie/upcoming"
    let page: Int
    
    var queryParameters: [String: String]? {
        [
            "language": "en-US",
            "page": String(page)
        ]
    }
}

private struct UpcomingMoviesRequest: RequestProtocol {
    typealias Response = UpcomingMoviesDTO
    let endpoint: EndpointProtocol
    let method: HTTP.Method = .get
}

// MARK: - Fetch Movie Details
private struct MovieDetailsEndpoint: EndpointProtocol {
    let base = Constants.apiBase
    let path: String
    
    init(movieID: Int) {
        path = "3/movie/\(movieID)"
    }
    
    var queryParameters: [String: String]? {
        ["language": "en-US"]
    }
}

private struct MovieDetailsRequest: RequestProtocol {
    typealias Response = MovieDetailsDTO
    let endpoint: EndpointProtocol
    let method: HTTP.Method = .get
}

// MARK: - DTOs
private struct UpcomingMoviesDTO: Codable {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    var mapped: UpcomingMovies {
        .init(
            page: page,
            movies: results.map { $0.mapped },
            totalPages: totalPages,
            totalResults: totalResults
        )
    }
}

private struct MovieDTO: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
    
    var mapped: UpcomingMovies.Movie {
        .init(
            movieID: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            releaseDate: releaseDate
        )
    }
}

private struct MovieDetailsDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let runtime: Int
    let voteAverage: Double
    let genres: [GenreDTO]
    let originalLanguage: String
    let backdropPath: String?
    let budget: Int
    let revenue: Int
    let status: String
    let tagline: String?
    let posterPath: String
    let releaseDate: String
    
    struct GenreDTO: Decodable {
        let id: Int
        let name: String
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
        }
        
        var mapped: MovieDetails.Genre {
            .init(
                id: id,
                name: name
            )
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case runtime
        case voteAverage = "vote_average"
        case genres
        case originalLanguage = "original_language"
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case budget
        case revenue
        case status
        case tagline
        case releaseDate = "release_date"
    }
    
    var mapped: MovieDetails {
        .init(
            id: id,
            title: title,
            overview: overview,
            runtime: runtime,
            voteAverage: voteAverage,
            genres: genres.map { $0.mapped },
            originalLanguage: originalLanguage,
            backdropPath: backdropPath,
            budget: budget,
            revenue: revenue,
            status: status,
            tagline: tagline
        )
    }
}


public struct Constants { //TODO: move to its own file
    static let apiBase = "https://api.themoviedb.org/"
}
