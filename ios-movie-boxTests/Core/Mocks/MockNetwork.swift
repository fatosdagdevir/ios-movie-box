import Foundation
@testable import ios_movie_box
import XCTest

final class MockNetwork: Networking {
    enum MockError: Error {
        case missingMockData
        case invalidResponse
    }
    
    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()
    
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    var mockData: Data?
    var mockError: Error?
    var statusCode: Int = 200
    
    // MARK: - Tracking Properties
    private(set) var capturedRequest: (any RequestProtocol)?
    private(set) var capturedURLRequest: URLRequest?
    private(set) var dataCallCount = 0
    
    func data(for request: some ios_movie_box.RequestProtocol) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let mockData = mockData else {
            throw MockError.missingMockData
        }
        
        let response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        
        if let error = NetworkError(response: response) {
            throw error
        }
        
        return (mockData, response)
    }
}
