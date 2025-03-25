import Foundation

protocol MovieListProviding {
    func fetchUpcomingMovies(page: Int) async throws -> UpcomingMoviesData
}

final class MovieListProvider: MovieListProviding {
    private let network: Networking
    init(network: Networking = Network()) {
        self.network = network
    }
    
    func fetchUpcomingMovies(page: Int) async throws -> UpcomingMoviesData {
        let endpoint = UpcomingMoviesEndpoint(page: page)
        let request = UpcomingMoviesRequest(endpoint: endpoint)
        let response = try await network.send(request: request)
        return response.mapped
    }
}

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
    typealias Response = MovieResponseDTO
    let endpoint: EndpointProtocol
    let method: HTTP.Method = .get
}

private struct MovieResponseDTO: Codable {
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
    
    var mapped: UpcomingMoviesData {
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
    
    var mapped: UpcomingMoviesData.Movie {
        .init(
            title: title,
            overview: overview,
            posterPath: posterPath,
            releaseDate: releaseDate
        )
    }
}

public struct Constants { //TODO: move to its own file
    static let apiBase = "https://api.themoviedb.org/"
}
