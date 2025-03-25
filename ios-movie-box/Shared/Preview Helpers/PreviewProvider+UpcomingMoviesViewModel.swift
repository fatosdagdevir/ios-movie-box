import SwiftUI

extension PreviewProvider {
    static func previewUpcomingMoviesViewModel(state: UpcomingMoviesView.ViewState) -> UpcomingMoviesViewModel {
        let viewModel = UpcomingMoviesViewModel(moviesProvider: MoviesProvider())
        viewModel.viewState = state
        return viewModel
    }
}

