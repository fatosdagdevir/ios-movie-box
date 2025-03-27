import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    init(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
    }
    
    @State private var image: Image?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = image {
                content(image)
            } else {
                placeholder()
                    .task(id: url) {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let loadedImage = try await ImageCache.shared.load(url) {
                withTransaction(transaction) {
                    image = loadedImage
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
}
