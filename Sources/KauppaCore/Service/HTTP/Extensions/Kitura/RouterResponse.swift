import Kitura

extension RouterResponse: ServiceResponse {
    public func respond<T: Mappable>(with data: T, code: HTTPStatusCode) {
        send(json: data)
        // FIXME: Our status code coincides with Kitura's
        // statusCode = HTTPStatusCode(rawValue: code.rawValue)
    }
}
