import Foundation
import SwiftyRequest

/// Wrapper class for `RestRequest` from `SwiftyRequest`
public class SwiftyRestRequest: ClientCallable {
    /// This is `RestResponse<Data>` wrapped in another class.
    public typealias Response = SwiftyRestResponse

    private let client: RestRequest

    /// Translates Kauppa's HTTP methods to SwiftyRequest's HTTP method.
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
            case .options:
                return .options
        }
    }

    public required init(with method: HTTPMethod, on url: URL) {
        let requestMethod = SwiftyRestRequest.translateMethod(from: method)
        self.client = RestRequest(method: requestMethod, url: url.absoluteString)
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
