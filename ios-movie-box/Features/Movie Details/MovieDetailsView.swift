import SwiftUI

struct MovieDetailsView: View {
    @ObservedObject var viewModel: MovieDetailsViewModel
    
    var body: some View {
        ScrollView {
            Text("Details View")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Movies")
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MovieDetailsView(
        viewModel: MovieDetailsViewModel()
    )
}
