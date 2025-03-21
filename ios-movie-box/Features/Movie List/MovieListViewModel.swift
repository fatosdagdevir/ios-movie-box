import Foundation
import Combine

protocol MovieListViewModelDelegate: AnyObject {
    func didRequestMovieDetail()
}

final class MovieListViewModel: ObservableObject {
    weak var delegate: MovieListViewModelDelegate?
    
    func didRequestMovieDetail() {
        delegate?.didRequestMovieDetail()
    }
}
