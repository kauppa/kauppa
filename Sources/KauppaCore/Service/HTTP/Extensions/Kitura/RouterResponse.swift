import Kitura
import KituraNet

extension RouterResponse: ServiceResponse {
    public func respond<T: Mappable>(with data: T, code: HTTPStatusCode) {
        statusCode = KituraNet.HTTPStatusCode(rawValue: Int(code.rawValue))!
        send(json: data)
    }
}
