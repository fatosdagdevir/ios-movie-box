import Foundation

extension URLRequest {
    init(
        endpoint: EndpointProtocol,
        method: HTTP.Method,
        timeoutInterval: TimeInterval,
        headers: [String: String]
    ) throws {
        guard let url = URL(endpoint: endpoint) else {
            throw Network.InternalError.invalidURL
        }
        
        self.init(url: url)
        
        self.httpMethod = method.rawValue
        self.timeoutInterval = timeoutInterval
        self.allHTTPHeaderFields = headers
    }
}
