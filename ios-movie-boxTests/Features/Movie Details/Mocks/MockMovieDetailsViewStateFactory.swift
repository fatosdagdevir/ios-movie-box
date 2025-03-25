@testable import ios_movie_box
import Foundation

final class MockMovieDetailsViewStateFactory: MovieDetailsViewStateCreating {
    func viewState(for movie: MovieDetails) -> MovieDetailsView.ViewState {
        return .ready(displayData: .mockDisplayData)
    }
}

extension MovieDetailsView.ViewState.DisplayData {
    static var mockDisplayData: MovieDetailsView.ViewState.DisplayData {
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
