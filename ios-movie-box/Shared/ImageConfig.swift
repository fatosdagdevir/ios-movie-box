import Foundation

enum ImageConfig {
    static let baseURL = "https://image.tmdb.org/t/p/"
    
    enum Size {
        static let backdropSmall = "w300"
        static let backdropMedium = "w780"
        static let backdropLarge = "w1280"
    }
    
    static func backdropURL(path: String?, size: String = Size.backdropMedium) -> URL? {
        guard let path = path else { return nil }
        return URL(string: baseURL + size + path)
    }
}
