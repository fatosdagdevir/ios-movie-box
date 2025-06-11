import Foundation

public protocol EndpointProtocol {
    var base: String { get }
    var path: String { get }
    var queryParameters: [String: String]? { get }
}

public extension EndpointProtocol {
    var queryParameters: [String: String]? { nil }
}
