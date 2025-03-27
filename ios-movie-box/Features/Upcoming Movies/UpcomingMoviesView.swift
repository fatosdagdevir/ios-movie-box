import SwiftUI

struct UpcomingMoviesView: View {
    enum ViewState {
        case loading
        case ready(movies: [UpcomingMovies.Movie])
        case error(viewModel: ErrorViewModel)
    }
    
    private enum Layout {
        static let vSpacing: CGFloat = 4
        static let verticalPadding: CGFloat = 16
        static let chevronPadding: CGFloat = 4
    }
    
    @ObservedObject var viewModel: UpcomingMoviesViewModel
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .accessibilityLabel("Loading upcoming movies")
            case .ready(let movies):
                content(movies: movies)
                    .refreshable {
                        await viewModel.refresh()
                    }
            case .error(let viewModel):
                ErrorView(viewModel: viewModel)
            }
        }
        .onFirstAppear {
            await viewModel.loadMovies()
        }
    }
    
    // MARK: - Movie List View
    @ViewBuilder
    private func content(movies: [UpcomingMovies.Movie]) -> some View {
        ScrollView {
            LazyVStack(spacing: Layout.vSpacing) {
                ForEach(movies, id: \.id) { movie in
                    movieRow(movie: movie)
                }
                
                loadingTriggerView
            }
            .padding(.vertical, Layout.verticalPadding)
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer,
            prompt: viewModel.searchBarTitle
        )
        .navigationTitle(viewModel.navigationTitle)
        .accessibilityLabel("Upcoming Movies List")
        .accessibilityAction(named: "Refresh List") {
            Task {
                await viewModel.refresh()
            }
        }
        .accessibilityHint("Double tap to refresh the movie list")
    }
    
    // MARK: - Moview Row View
    @ViewBuilder
    private func movieRow(movie: UpcomingMovies.Movie) -> some View {
        HStack {
            Text(movie.title)
                .font(.subheadline)
            
            Spacer()
            
            chevronIcon
        }
        .padding()
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.didSelect(movie: movie)
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(movie.title)
        .accessibilityHint("Double tap to view movie details")
        .accessibilityAddTraits(.isButton)
        
        Divider()
            .foregroundColor(.gray)
            .accessibilityHidden(true)
    }
    
    // MARK: - Load Trigger View
    @ViewBuilder
    private var loadingTriggerView: some View {
        if viewModel.nextPageAvailable && !viewModel.isSearching {
            ProgressView()
                .frame(maxWidth: .infinity)
                .task {
                    viewModel.loadMoreIfNeeded()
                }
                .accessibilityLabel("Loading more movies")
                .accessibilityHidden(!viewModel.nextPageAvailable)
        }
    }
    
    @ViewBuilder
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(.gray)
            .padding(.leading, Layout.chevronPadding)
            .accessibilityHidden(true)
    }
}

// MARK: - Previews
struct UpcomingMoviesView_Previews: PreviewProvider {
    static var previews: some View {
        // MARK: Ready
        UpcomingMoviesView(
            viewModel: previewUpcomingMoviesViewModel(
                state: .ready(movies: previewUpcomingMovies)
            )
        )
        
        // MARK: Loading
        UpcomingMoviesView(
            viewModel: previewUpcomingMoviesViewModel(
                state: .loading)
            
        )
        
        // MARK: Error
        UpcomingMoviesView(
            viewModel: previewUpcomingMoviesViewModel(
                state: .error(viewModel: previewErrorViewModel)
            )
        )
    }
}
