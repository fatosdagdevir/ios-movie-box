import Foundation

protocol MovieDetailsViewModelDelegate: AnyObject {
    func dismiss()
}

final class MovieDetailsViewModel: ObservableObject {
    weak var delegate: MovieDetailsViewModelDelegate?
    
    func dismiss() {
        delegate?.dismiss()
    }
}
