import SwiftUI

extension PreviewProvider {
    static var previewMovies: [UpcomingMovies.Movie] {
        [
            mockMovie1,
            mockMovie2,
            mockMovie3,
            .init(
                movieID: 4,
                title: "No Poster Movie",
                overview: "Test movie",
                posterPath: nil,
                releaseDate: "2024"
            )
        ]
    }
    
    static var mockMovie1: UpcomingMovies.Movie {
        .init(
            movieID: 1,
            title: "The Dark Knight",
            overview: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.",
            posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
            releaseDate: "2024-03-15"
        )
    }
    
    static var mockMovie2: UpcomingMovies.Movie  {
        .init(
            movieID: 2,
            title: "Inception",
            overview: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
            posterPath: "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
            releaseDate: "2024-04-20"
        )
    }
    
    static var mockMovie3: UpcomingMovies.Movie {
        .init(
            movieID: 3,
            title: "Interstellar",
            overview: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
            posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
            releaseDate: "2024-05-01"
        )
    }
}
