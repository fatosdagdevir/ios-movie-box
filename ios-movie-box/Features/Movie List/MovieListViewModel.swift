import Foundation
import Combine

protocol MovieListViewModelDelegate: AnyObject {
    func didRequestMovieDetail()
}

final class MovieListViewModel: ObservableObject {
    private let movieListProvider: MovieListProviding
    private var pagination: Pagination
    private var movies: [UpcomingMoviesData.Movie] = []
    
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var viewState: MovieListView.ViewState = .loading
    
    var navigationTitle: String { "Upcoming Movies" }
    var nextPageAvailable: Bool { pagination.hasNextPage }
    
    weak var delegate: MovieListViewModelDelegate?
    
    init(
        movieListProvider: MovieListProviding,
        pagination: Pagination = .init()
    ) {
        self.movieListProvider = movieListProvider
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
            let response = try await movieListProvider.fetchUpcomingMovies(
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
    
    private func handleSuccess(_ data: UpcomingMoviesData) {
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
    
    func didRequestMovieDetail() {
        delegate?.didRequestMovieDetail()
    }
}

// MARK: - Pagination Helper
extension MovieListViewModel {
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
