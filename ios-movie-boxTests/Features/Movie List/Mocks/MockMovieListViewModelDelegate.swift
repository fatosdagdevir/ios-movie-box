@testable import ios_movie_box

final class MockMovieListViewModelDelegate: MovieListViewModelDelegate {
    var didRequestMovieDetailCalled = false
    var didRequestMovieDetailCallCount = 0
    
    func didRequestMovieDetail( _ movieID: Int) {
        didRequestMovieDetailCalled = true
        didRequestMovieDetailCallCount += 1
    }
}
