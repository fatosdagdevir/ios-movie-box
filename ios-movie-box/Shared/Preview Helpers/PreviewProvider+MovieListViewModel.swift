import SwiftUI

extension PreviewProvider {
    static func previewMovieListViewModel(state: MovieListView.ViewState) -> MovieListViewModel {
        let viewModel = MovieListViewModel(movieListProvider: MoviesProvider())
        viewModel.viewState = state
        return viewModel
    }
}

