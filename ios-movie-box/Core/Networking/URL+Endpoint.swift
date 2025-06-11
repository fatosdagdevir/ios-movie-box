import Foundation

extension URL {
    init?(endpoint: EndpointProtocol) {
        let absoluteURLString = "\(endpoint.base)/\(endpoint.path)"
        
        guard var components = URLComponents(string: absoluteURLString) else {
            return nil
        }
        
        if let parameters = endpoint.queryParameters {
            components.queryItems = parameters.map { .init(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            return nil
        }
        self = url
    }
}
