import SwiftUI

struct ErrorView: View {
    private enum Layout {
        static let vSpacing = 16.0
        static let horizontalPadding = 20.0
        static let buttonHeight = 44.0
    }
    
    @ObservedObject private(set) var viewModel: ErrorViewModel
    
    var body: some View {
        VStack(spacing: Layout.vSpacing) {
            Text(viewModel.headerText)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(viewModel.descriptionText)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Layout.horizontalPadding)
            
            Button {
                Task { [weak viewModel] in
                    await viewModel?.action()
                }
            } label: {
                Text(viewModel.buttonTitle)
                    .fontWeight(.semibold)
                    .frame(height: Layout.buttonHeight)
            }
        }
    }
}

#Preview("Generic Error") {
    ErrorView(
        viewModel: ErrorViewModel(
            error: NetworkError.unknown,
            action: { }
        )
    )
}

#Preview("Offline Error") {
    ErrorView(
        viewModel: ErrorViewModel(
            error: NetworkError.offline,
            action: { }
        )
    )
}
