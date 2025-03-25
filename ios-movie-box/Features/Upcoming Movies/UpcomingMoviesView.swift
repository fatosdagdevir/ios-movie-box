import SwiftUI

struct UpcomingMoviesView: View {
    enum ViewState {
        case loading
        case ready(movies: [UpcomingMovies.Movie])
        case error(viewModel: ErrorViewModel)
    }
    
    private enum Layout {
        static let vSpacing: CGFloat = 16
        static let verticalPadding: CGFloat = 24
        static let chevronPadding: CGFloat = 4
    }
    
    @ObservedObject var viewModel: UpcomingMoviesViewModel
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .ready(let movies):
                content(movies: movies)
                    .refreshable {
                        await viewModel.refresh()
                    }
            case .error(let viewModel):
                ErrorView(viewModel: viewModel)
            }
        }
        .task {
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
                        .onTapGesture {
                            viewModel.didSelect(movie: movie)
                        }
                }
                
                loadingTriggerView
            }
            .padding(.vertical, Layout.verticalPadding)
        }
        .navigationTitle(viewModel.navigationTitle)
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
        
        Divider()
            .foregroundColor(.gray)
    }
    
    // MARK: - Load Trigger View
    @ViewBuilder
    private var loadingTriggerView: some View {
        if viewModel.nextPageAvailable {
            ProgressView()
                .frame(maxWidth: .infinity)
                .task {
                    viewModel.loadMoreIfNeeded()
                }
        }
    }
    
    @ViewBuilder
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(.gray)
            .padding(.leading, Layout.chevronPadding)
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
