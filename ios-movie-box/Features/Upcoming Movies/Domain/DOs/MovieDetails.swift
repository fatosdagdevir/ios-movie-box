import Foundation

struct MovieDetails: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let runtime: Int
    let voteAverage: Double
    let genres: [Genre]
    let originalLanguage: String
    let backdropPath: String?
    let budget: Int
    let revenue: Int
    let status: String
    let tagline: String?
    
    struct Genre {
        let id: Int
        let name: String
    }
}
