import Foundation

public enum HTTP {
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    public enum RequestHeaderKey: String {
        case authorization = "Authorization"
        case contentType = "Content-Type"
    }
}
