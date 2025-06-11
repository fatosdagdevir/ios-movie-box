import Foundation

enum NetworkError: Error {
    case invalidStatus(Int)
    case serverError(Int)
    case offline
    case unknown
    
    var statusCode: Int {
        switch self {
        case .invalidStatus(let code), .serverError(let code):
            return code
        case .unknown, .offline:
            return 0
        }
    }
    
    private static let offlineCodes: Set<URLError.Code> = [
        .notConnectedToInternet,
        .networkConnectionLost,
        .dataNotAllowed,
        .internationalRoamingOff,
        .timedOut
    ]
    
    var isOfflineError: Bool {
        if case .offline = self {
            return true
        }
        return false
    }
    
    init?(error: Error) {
        if let urlError = error as? URLError,
           Self.offlineCodes.contains(urlError.code) {
            self = .offline
        } else {
            self = .unknown
        }
    }
    
    init?(response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return nil
        case 500...599:
            self = .serverError(httpResponse.statusCode)
        default:
            self = .invalidStatus(httpResponse.statusCode)
        }
    }
}

extension NetworkError {
    static func handle(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        return NetworkError(error: error) ?? .unknown
    }
}
