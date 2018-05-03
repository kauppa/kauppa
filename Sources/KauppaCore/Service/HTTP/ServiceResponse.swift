import Foundation

/// Protocol to be implemented by outgoing response object.
public protocol ServiceResponse {
    /// Send this data into stream and respond with the given
    /// status code. Note that the implementation should close this stream.
    ///
    /// - Parameters:
    ///   - with: The raw `Data` for the response body.
    ///   - code: The `HTTPStatusCode` for the response.
    func respond(with data: Data, code: HTTPStatusCode)

    /// Set the header for this response.
    ///
    /// - Parameters:
    ///   - key: The name of the header.
    ///   - value: The value for the header.
    func setHeader(key: String, value: String)
}

extension ServiceResponse {
    /// Default method for responding with a JSON object and a status code.
    /// This also sets the `Content-Type` header to `application/json` in the response.
    ///
    /// - Parameters:
    ///   - with: The `Mappable` object to be encoded.
    ///   - code: The `HTTPStatusCode` to be set for the response.
    public func respondJSON<T: Mappable>(with data: T, code: HTTPStatusCode = .ok) throws {
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        // NOTE: This should be same as the one in `ClientCallable`, `ServiceClient` and `ServiceRequest` implementation.
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        // FIXME: Remove this!
        self.setHeader(key: "Access-Control-Allow-Origin", value: "*")

        self.setHeader(key: "Content-Type", value: "application/json")

        do {
            let encoded = try encoder.encode(data)
            self.respond(with: encoded, code: code)
        } catch {
            throw ServiceError.jsonSerialization
        }
    }
}
