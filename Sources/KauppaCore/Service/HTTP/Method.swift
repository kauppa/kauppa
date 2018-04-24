import Foundation

/// HTTP methods for routes (required by Kauppa).
public enum HTTPMethod: UInt8 {
    case get
    case post
    case put
    case patch
    case delete
    case options
}

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .patch:
                return "PATCH"
            case .delete:
                return "DELETE"
            case .options:
                return "OPTIONS"
        }
    }
}
