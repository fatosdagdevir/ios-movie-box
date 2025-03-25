import SwiftUI

struct MovieDetailsView: View {
    enum ViewState: Equatable {
        case loading
        case ready(displayData: DisplayData)
        case error(viewModel: ErrorViewModel)
        
        struct DisplayData: Equatable {
            let imageURL: URL?
            let title: String
            let overviewTitle: String
            let overview: String
            let genreList: String
            let rating: String
        }
    }
    
    private enum Layout {
        enum Header {
            static let vspacing: CGFloat = 8
        }
        enum Details {
            static let vspacing: CGFloat = 8
        }
        static let imageAspectRatio: CGFloat = 780/439
        static let padding: CGFloat = 16
    }
    
    @ObservedObject var viewModel: MovieDetailsViewModel
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .ready(let viewData):
                ScrollView {
                    VStack {
                        headerSection(viewData: viewData)
                        detailsSection(viewData)
                    }
                }
            case .error(let viewModel):
                ErrorView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadMovieDetails()
        }
    }
    
    // MARK: - Header Section
    private func headerSection(viewData: ViewState.DisplayData) -> some View {
        ZStack(alignment: .bottomLeading) {
            headerImage(from: viewData.imageURL)
            
            // Title and Info
            VStack(alignment: .leading, spacing: Layout.Header.vspacing) {
                Text(viewData.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(viewData.rating)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                Text(viewData.genreList)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(Layout.padding)
        }
    }
    
    // MARK: - Details Section
    private func detailsSection(_ viewData: ViewState.DisplayData) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Layout.Details.vspacing) {
                Text(viewData.overviewTitle)
                    .font(.headline)
                
                Text(viewData.overview)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(Layout.padding)
    }
    
    // MARK: - Private Helpers
    @ViewBuilder private func headerImage(from imageUrl: URL?) -> some View {
        AsyncImage(url: imageUrl, content: { image in
            image
                .resizable()
                .aspectRatio(Layout.imageAspectRatio, contentMode: .fit)
        }, placeholder: {
            placeholderImage
        })
        .accessibilityHidden(true)
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .aspectRatio(Layout.imageAspectRatio, contentMode: .fit)
    }
}

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        
        // MARK: Ready
        MovieDetailsView(
            viewModel: previewMovieDetailsViewModel(
                state: .ready(displayData: previewMovieDetailsDisplayData)
            )
        )
        
        // MARK: Loading
        MovieDetailsView(
            viewModel: previewMovieDetailsViewModel(
                state: .loading
            )
        )
        
        // MARK: Error
        MovieDetailsView(
            viewModel: previewMovieDetailsViewModel(
                state: .error(viewModel: previewErrorViewModel)
            )
        )
    }
}
