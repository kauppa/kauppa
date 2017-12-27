import Foundation

import KauppaCore

struct TestClientResponse: ClientResponse {
    var code: HTTPStatusCode? = nil
    var data: Data? = nil

    var statusCode: HTTPStatusCode {
        return code ?? .unknown
    }

    func getData() -> Data? {
        return data
    }
}

typealias DataCallback = (Data) -> Void

struct TestClient: ClientCallable {
    public typealias Response = TestClientResponse

    var dataCallback: DataCallback? = nil
    var headerCallback: HeaderCallback? = nil
    var response: Response? = nil

    let method: HTTPMethod
    let url: URL

    public init(with method: HTTPMethod, on url: URL) {
        self.method = method
        self.url = url
    }

    public func setHeader(key: String, value: String) {
        if let callback = headerCallback {
            callback(key, value)
        }
    }

    public func setData(_ data: Data) {
        if let callback = dataCallback {
            callback(data)
        }
    }

    public func requestRaw(_ handler: @escaping (Response) -> Void) {
        if let response = response {
            handler(response)
        }
    }
}
