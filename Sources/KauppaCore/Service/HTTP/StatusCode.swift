/// Status codes for HTTP responses (required by Kauppa).
public enum StatusCode: UInt16 {
    case ok                     = 200
    case badRequest             = 400
    case unauthorized           = 401
    case forbidden              = 403
    case notFound               = 404
    case internalServerError    = 500
}

/// Represents objects which are associated with a status codes.
public protocol StatusCodeConvertible {
    /// Get the status code for this object.
    func statusCode() -> StatusCode
}
