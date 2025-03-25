import SwiftUI

extension PreviewProvider {
    static func previewMovieDetailsViewModel(state: MovieDetailsView.ViewState) -> MovieDetailsViewModel {
        let viewModel = MovieDetailsViewModel(
            movieID: 1,
            moviesProvider: MoviesProvider(),
            movieDetailsViewStateFactory: MovieDetailsViewStateFactory()
        )
        viewModel.viewState = state
        return viewModel
    }
}
