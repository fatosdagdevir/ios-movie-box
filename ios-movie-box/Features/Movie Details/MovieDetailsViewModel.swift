import Foundation

final class MovieDetailsViewModel: ObservableObject {
    private let moviesProvider: MoviesProviding
    private let movieDetailsViewStateFactory: MovieDetailsViewStateCreating
    private let movieID: Int
    
    @Published var viewState: MovieDetailsView.ViewState = .loading
    
    init(
        movieID: Int,
        moviesProvider: MoviesProviding,
        movieDetailsViewStateFactory: MovieDetailsViewStateCreating
    ) {
        self.movieID = movieID
        self.moviesProvider = moviesProvider
        self.movieDetailsViewStateFactory = movieDetailsViewStateFactory
    }
    
    @MainActor
    func loadMovieDetails() async {
        do {
            let response = try await moviesProvider.fetchMovieDetails(id: movieID)
            viewState = movieDetailsViewStateFactory.viewState(for: response)
        } catch {
            handleError(error)
        }
    }
    
    @MainActor
    func refresh() async {
        viewState = .loading
        
        await loadMovieDetails()
    }
    
    private func handleError(_ error: Error) {
        viewState = .error(
            viewModel: ErrorViewModel(
                error: NetworkError.handle(error),
                action: {  [weak self] in
                    await self?.refresh()
                }
            )
        )
    }
}
