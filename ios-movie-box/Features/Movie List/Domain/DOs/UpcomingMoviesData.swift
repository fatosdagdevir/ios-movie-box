import Foundation

struct UpcomingMoviesData: Equatable {
    let page: Int
    let movies: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    struct Movie: Equatable, Identifiable {
        let id = UUID()
        let title: String
        let overview: String
        let posterPath: String?
        let releaseDate: String
    }
}
