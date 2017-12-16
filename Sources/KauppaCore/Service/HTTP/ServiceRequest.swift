/// Protocol to be implemented by incoming request object.
public protocol ServiceRequest {
    /// Parse this stream as a `Mappable` object.
    func getJson<T: Mappable>() throws -> T
}
