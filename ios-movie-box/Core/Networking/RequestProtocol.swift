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
            HTTP.RequestHeaderKey.authorization.rawValue: "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4MDVkZGU4YmYyMWFmYmJjNTY0Yjc0N2M5ZTIzNWQxYiIsIm5iZiI6MTc0MjY4MTg0MS4xODIwMDAyLCJzdWIiOiI2N2RmMzZmMWU0YTljODY5MDYwN2I4MDEiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.GiiTThDOseMhANAIgHeE16mw8Yhs8KYF-l_vFPATpMg"
        ]
    }
}
