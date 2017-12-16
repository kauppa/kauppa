import Kitura

extension RouterResponse: ServiceResponse {
    public func respond<T: Mappable>(with data: T, code: StatusCode) {
        // TODO
    }
}
