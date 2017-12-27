/// Protocol to be implemented by incoming request object.
public protocol ServiceRequest {
    /// Get the value for the given key from the header (if it exists).
    func getHeader(for key: String) -> String?

    /// Get the URL parameter for the given key. This should also try to parse
    /// the parameter into the given type.
    func getParameter<T: StringParsable>(for key: String) -> T?

    /// Parse this stream as a `Mappable` object.
    func getJSON<T: Mappable>() -> T?
}
