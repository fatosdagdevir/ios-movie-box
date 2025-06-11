import Foundation

protocol MovieDetailsViewStateCreating {
    func viewState(for movie: MovieDetails) -> MovieDetailsView.ViewState
}

struct MovieDetailsViewStateFactory: MovieDetailsViewStateCreating {
    func viewState(for movie: MovieDetails) -> MovieDetailsView.ViewState {
        
        let displayData: MovieDetailsView.ViewState.DisplayData = .init(
            imageURL: imageURL(for: movie),
            title: movie.title,
            overviewTitle: "Overview",
            overview: movie.overview,
            genreList: genreList(for: movie),
            rating: formattedRating(for: movie)
        )
        return .ready(displayData: displayData)
    }
    
    // MARK: - Helpers
    private func genreList(for movie: MovieDetails) -> String {
        movie.genres.map(\.name).joined(separator: ", ")
    }
    
    private func imageURL(for movie: MovieDetails) -> URL? {
        guard let backdropPath = movie.backdropPath  else {
            return nil
        }
        return ImageConfig.backdropURL(path: backdropPath)
    }
    
    private func formattedRating(for movie: MovieDetails) -> String {
        String(format: "Rating: %.1f", movie.voteAverage)
    }
}
