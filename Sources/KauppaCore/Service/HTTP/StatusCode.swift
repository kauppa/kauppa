/// Status codes for HTTP responses (required by Kauppa).
public enum HTTPStatusCode: UInt16 {
    case ok                     = 200
    case badRequest             = 400
    case unauthorized           = 401
    case forbidden              = 403
    case notFound               = 404
    case internalServerError    = 500
}
