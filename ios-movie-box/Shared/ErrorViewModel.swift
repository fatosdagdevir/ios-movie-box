import Foundation
import Combine

final class ErrorViewModel: ObservableObject {
    private enum ErrorType: Equatable {
        case offline
        case generic
    }
    
    typealias ActionHandler = @MainActor () async -> Void
    
    let action: ActionHandler
    let error: Error
    private let type: ErrorType
    
    var headerText: String {
        switch type {
        case .offline:
            "You are offline!"
        case .generic:
            "Oops!"
        }
    }

    var descriptionText: String {
        switch type {
        case .offline:
            "Please check your internet connection and try again."
        case .generic:
            "Something wrong happened try again."
        }
    }
    
    var buttonTitle: String { "Retry" }
    
    init(
        error: Error,
        action: @escaping ActionHandler
    ) {
        self.error = error
        self.action = action
        self.type = (error as? NetworkError)?.isOfflineError == true ? .offline : .generic
    }
}
