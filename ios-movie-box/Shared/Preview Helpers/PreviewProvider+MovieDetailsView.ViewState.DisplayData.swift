import SwiftUI

extension PreviewProvider {
    static var previewMovieDetailsDisplayData: MovieDetailsView.ViewState.DisplayData {
        .init(
            imageURL: URL(string: "https://image.tmdb.org/t/p/original/dark-knight-backdrop.jpg"),
            title: "The Dark Knight",
            overviewTitle: "Overview",
            overview: "Batman raises the stakes in his war on crime.",
            genreList: "Action, Drama, Crime",
            rating: "8.5/10"
        )
    }
}
