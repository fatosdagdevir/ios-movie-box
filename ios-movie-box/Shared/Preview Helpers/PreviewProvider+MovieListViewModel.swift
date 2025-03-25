import SwiftUI

extension PreviewProvider {
    static func previewMovieListViewModel(state: UpcomingMoviesView.ViewState) -> UpcomingMoviesViewModel {
        let viewModel = UpcomingMoviesViewModel(moviesProvider: MoviesProvider())
        viewModel.viewState = state
        return viewModel
    }
}

