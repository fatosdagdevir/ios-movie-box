import Foundation
import Combine

protocol UpcomingMoviesViewModelDelegate: AnyObject {
    func didRequestMovieDetail(_ movieID: Int)
}

final class UpcomingMoviesViewModel: ObservableObject {
    private let moviesProvider: MoviesProviding
    private var pagination: Pagination
    private var upcomingMovies: [UpcomingMovies.Movie] = []
    private var searchedMovies: [UpcomingMovies.Movie] = []
    
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var viewState: UpcomingMoviesView.ViewState = .loading
    @Published var searchText = ""
    
    var navigationTitle: String { "Upcoming Movies" }
    var searchBarTitle: String { "Search movies..." }
    var nextPageAvailable: Bool { pagination.hasNextPage }
    var isSearching: Bool { !searchText.isEmpty }
    
    weak var delegate: UpcomingMoviesViewModelDelegate?
    
    init(
        moviesProvider: MoviesProviding,
        pagination: Pagination = .init()
    ) {
        self.moviesProvider = moviesProvider
        self.pagination = pagination
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        setupLoadMoreSubscription()
        setupSearchSubscription()
    }
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                Task {
                    await self.searchMovies(query: searchText)
                }
            }
            .store(in: &cancellables)
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
        guard pagination.hasNextPage && !isSearching else { return }
        
        loadMoreSubject.send()
    }
    
    @MainActor
    func loadMovies() async {
        guard pagination.hasNextPage else { return }
        
        do {
            let response = try await moviesProvider.fetchUpcomingMovies(
                page: pagination.currentPage
            )
            handleUpcomingMoviesResult(response)
            pagination.incrementPage()
        } catch {
            handleError(error)
        }
    }
    
    @MainActor
    func refresh() async {
        pagination.reset()
        upcomingMovies.removeAll()
        searchedMovies.removeAll()
        viewState = .loading
        
        await loadMovies()
    }
    
    private func handleUpcomingMoviesResult(_ data: UpcomingMovies) {
        pagination.update(totalPages: data.totalPages)
        upcomingMovies.append(contentsOf: data.movies)
        upcomingMovies = upcomingMovies.uniqued()
        viewState = .ready(movies: upcomingMovies)
    }
    
    //MARK: Search
    @MainActor
    func searchMovies(query: String) async {
        guard !query.isEmpty else {
            searchedMovies.removeAll()
            viewState = .ready(movies: upcomingMovies)
            return
        }
        
        do {
            let response = try await moviesProvider.searchMovies(
                query: query,
                page: 1 //TODO: pagination
            )
            handleSearchedMoviesResult(response)
        } catch {
            handleError(error)
        }
    }
    
    private func handleSearchedMoviesResult(_ data: UpcomingMovies) {
        let searchedMovies = data.movies.uniqued()
        viewState = .ready(movies: searchedMovies)
    }
    
    //MARK: Error Handling
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
    
    //MARK: Navigation
    func didSelect(movie: UpcomingMovies.Movie) {
        delegate?.didRequestMovieDetail(movie.id)
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

// MARK: - Common Helpers
private extension Array where Element: Identifiable {
    func uniqued() -> [Element] {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}
