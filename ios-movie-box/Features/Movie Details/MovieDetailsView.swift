import SwiftUI

struct MovieDetailsView: View {
    @ObservedObject var viewModel: MovieDetailsViewModel
    
    var body: some View {
        Text("Details View")
    }
}

#Preview {
    MovieDetailsView(
        viewModel: MovieDetailsViewModel()
    )
}
