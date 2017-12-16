/// Protocol to be implemented by outgoing response object.
public protocol ServiceResponse {
    /// Encode this `Mappable` object as JSON data into stream and respond with the given
    /// status code. Note that the implementation should close this stream.
    func respond<T: Mappable>(with data: T, code: StatusCode)
}
