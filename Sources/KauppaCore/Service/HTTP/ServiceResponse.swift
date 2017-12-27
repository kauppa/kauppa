import Foundation

/// Protocol to be implemented by outgoing response object.
public protocol ServiceResponse {
    /// Send this data into stream and respond with the given
    /// status code. Note that the implementation should close this stream.
    func respond(with data: Data, code: HTTPStatusCode)
}

extension ServiceResponse {
    public func respondJSON<T: Mappable>(with data: T, code: HTTPStatusCode) {
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        // NOTE: This should be same as `ServiceClient` implementation.
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let encoded = try! encoder.encode(data)
        self.respond(with: encoded, code: code)
    }
}
