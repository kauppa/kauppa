import Foundation

import Kitura
import KituraNet

extension RouterResponse: ServiceResponse {
    public func respond(with data: Data, code: HTTPStatusCode) {
        statusCode = KituraNet.HTTPStatusCode(rawValue: Int(code.rawValue))!
        send(data: data)
    }

    public func setHeader(key: String, value: String) {
        headers.append(key, value: value)
    }
}
