import SwiftUI

struct MovieListView: View {
    @ObservedObject var viewModel: MovieListViewModel
    
    var body: some View {
        VStack {
            Text("Movie List View")
            Button("Tap Details") {
                viewModel.didRequestMovieDetail()
            }
        }
    }
}

#Preview {
    MovieListView(viewModel: MovieListViewModel())
}
