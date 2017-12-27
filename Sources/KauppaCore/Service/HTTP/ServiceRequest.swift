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

    /// Get the JSON object from this stream.
    ///
    /// - Returns: The decoded `Mappable`  object.
    func getJSON<T: Mappable>() -> T?
}
