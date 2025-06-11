import SwiftUI

extension PreviewProvider {
    static var previewErrorViewModel: ErrorViewModel {
        .init(
            error: NetworkError.unknown,
            action: {}
        )
    }
}
