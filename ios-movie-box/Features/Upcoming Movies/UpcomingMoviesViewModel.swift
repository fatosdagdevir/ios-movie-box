import Foundation
import Combine

protocol UpcomingMoviesViewModelDelegate: AnyObject {
    func didRequestMovieDetail(_ movieID: Int)
}

final class UpcomingMoviesViewModel: ObservableObject {
    private let moviesProvider: MoviesProviding
    private var pagination: Pagination
    private var movies: [UpcomingMovies.Movie] = []
    
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var viewState: UpcomingMoviesView.ViewState = .loading
    
    var navigationTitle: String { "Upcoming Movies" }
    var nextPageAvailable: Bool { pagination.hasNextPage }
    
    weak var delegate: UpcomingMoviesViewModelDelegate?
    
    init(
        moviesProvider: MoviesProviding,
        pagination: Pagination = .init()
    ) {
        self.moviesProvider = moviesProvider
        self.pagination = pagination
        
        setupLoadMoreSubscription()
    }
    
    private func setupLoadMoreSubscription() {
        loadMoreSubject
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                Task {
                    await self.loadMovies()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadMoreIfNeeded() {
        guard pagination.hasNextPage else { return }
        
        loadMoreSubject.send()
    }
    
    @MainActor
    func loadMovies() async {
        guard pagination.hasNextPage else { return }
        
        do {
            let response = try await moviesProvider.fetchUpcomingMovies(
                page: pagination.currentPage
            )
            handleSuccess(response)
            pagination.incrementPage()
        } catch {
            handleError(error)
        }
    }
    
    @MainActor
    func refresh() async {
        pagination.reset()
        movies.removeAll()
        viewState = .loading
        
        await loadMovies()
    }
    
    private func handleSuccess(_ data: UpcomingMovies) {
        pagination.update(totalPages: data.totalPages)
        movies.append(contentsOf: data.movies)
        viewState = .ready(movies: movies)
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
    
    func didSelect(movie: UpcomingMovies.Movie) {
        delegate?.didRequestMovieDetail(movie.movieID)
    }
}

// MARK: - Pagination Helper
extension UpcomingMoviesViewModel {
    struct Pagination {
        private(set) var currentPage: Int = 1
        private(set) var totalPages: Int = 1
        
        var hasNextPage: Bool { currentPage <= totalPages }
        
        mutating func incrementPage() {
            currentPage += 1
        }
        
        mutating func update(totalPages: Int) {
            self.totalPages = totalPages
        }
        
        mutating func reset() {
            currentPage = 1
            totalPages = 1
        }
    }
}
