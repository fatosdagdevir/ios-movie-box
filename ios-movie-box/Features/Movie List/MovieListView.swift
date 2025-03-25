import SwiftUI

struct MovieListView: View {
    enum ViewState {
        case loading
        case ready(movies: [UpcomingMoviesData.Movie])
        case error(viewModel: ErrorViewModel)
    }
    
    private enum Layout {
        static let vSpacing: CGFloat = 16
        static let verticalPadding: CGFloat = 24
        static let chevronPadding: CGFloat = 4
    }
    
    @ObservedObject var viewModel: MovieListViewModel
    
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
    
    @ViewBuilder
    private func content(movies: [UpcomingMoviesData.Movie]) -> some View {
        ScrollView {
            LazyVStack(spacing: Layout.vSpacing) {
                
                ForEach(movies, id: \.id, content: movieRow)
                
                loadingTriggerView
            }
            .padding(.vertical, Layout.verticalPadding)
        }
        .navigationTitle(viewModel.navigationTitle)
    }
    
    @ViewBuilder
    private func movieRow(movie: UpcomingMoviesData.Movie) -> some View {
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
    
    @ViewBuilder
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(.gray)
            .padding(.leading, Layout.chevronPadding)
    }
    
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
}

//TODO: add preview
