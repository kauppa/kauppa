import Foundation
import SwiftyRequest

public class SwiftyRestRequest: ClientCallable {
    public typealias Response = SwiftyRestResponse

    private let client: RestRequest

    static func translateMethod(from method: HTTPMethod) -> SwiftyRequest.HTTPMethod {
        switch method {
            case .get:
                return .get
            case .post:
                return .post
            case .put:
                return .put
            case .patch:
                return .patch
            case .delete:
                return .delete
        }
    }

    public required init(with method: HTTPMethod, on url: URL) {
        let requestMethod = SwiftyRestRequest.translateMethod(from: method)
        self.client = RestRequest(method: requestMethod, url: "\(url)")
    }

    public func setHeader(key: String, value: String) {
        self.client.headerParameters[key] = value
    }

    public func setData(_ data: Data) {
        self.client.messageBody = data
    }

    public func requestRaw(_ handler: @escaping (Response) -> Void) {
        self.client.responseData(templateParams: nil, queryItems: nil, completionHandler: { response in
            handler(SwiftyRestResponse(with: response))
        })
    }
}
