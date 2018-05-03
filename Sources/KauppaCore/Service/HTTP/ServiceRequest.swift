import Foundation

/// Protocol to be implemented by incoming request object.
public protocol ServiceRequest {
    /// Get the value for the given key from the header (if it exists).
    ///
    /// - Parameters:
    ///   - for: The name of the header.
    /// - Returns: The value for that header (if it exists).
    func getHeader(for key: String) -> String?

    /// Get the URL parameter for the given key. This should also try to parse
    /// the parameter into the given type.
    ///
    /// - Parameters:
    ///   - for: The name of the parameter.
    /// - Returns: The parsed object (if it exists) and if it was parseable.
    func getParameter<T: StringParsable>(for key: String) -> T?

    /// Get the raw body of this request.
    ///
    /// - Returns: The `Data` object.
    func getData() -> Data?
}

extension ServiceRequest {
    /// Get the JSON object from this stream.
    ///
    /// - Returns: The decoded `Mappable` object.
    public func getJSON<T: Mappable>() -> T? {
        guard let data = self.getData() else {
            return nil
        }

        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        // NOTE: This format should be same as the one in `ClientCallable`, `ServiceResponse` and `ServiceClient` implementation.
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try? decoder.decode(T.self, from: data)
    }
}
