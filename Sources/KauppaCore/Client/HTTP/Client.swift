import Foundation

open class HTTPClient<C: ClientCallable>: ClientCallable {
    public typealias Response = C.Response
    public typealias ClientError = C.ClientError

    private let client: C

    public required init(with method: HTTPMethod, on url: String) {
        self.client = C(with: method, on: url)
    }

    public func setBody(using data: Data) {
        self.client.setBody(using: data)
    }

    public func requestRaw(_ handler: @escaping (Response) throws -> Void) {
        self.client.requestRaw(handler)
    }

    public func request<D: Mappable>(_ handler: @escaping (D) throws -> Void) {
        self.requestRaw() { response in
            guard let data = response.getData() else {
                throw GenericError.clientHTTPData
            }

            let code = response.statusCode
            if code.rawValue < 400 {
                do {
                    let jsonData: D = try JSONDecoder().decode(D.self, from: data)
                    try handler(jsonData)
                } catch {
                    throw GenericError.jsonParse
                }

                return
            }

            do {
                let error = try JSONDecoder().decode(MappableServiceError.self, from: data)
                guard let serviceError = ClientError(rawValue: error.code) else {
                    throw GenericError.jsonErrorParse
                }

                throw serviceError
            } catch {
                throw GenericError.jsonErrorParse
            }
        }
    }
}
