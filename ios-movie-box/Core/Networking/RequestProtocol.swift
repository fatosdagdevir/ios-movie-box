import Foundation

public protocol RequestProtocol {
    associatedtype Response: Decodable = EmptyResponse

    var endpoint: EndpointProtocol { get }
    var body: Encodable? { get }
    var method: HTTP.Method { get }
    var headers: [String: String] { get }
}

public struct EmptyResponse: Decodable {}

public extension RequestProtocol {
    var body: Encodable? { nil }
    var headers: [String: String] {
        [
            HTTP.RequestHeaderKey.contentType.rawValue: "application/json",
            HTTP.RequestHeaderKey.authorization.rawValue: "Bearer XXX"
        ]
    }
}
