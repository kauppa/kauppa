import Foundation

import KauppaCore

/// Wrapper object around the response which is responsible for translating the
/// JSON data from the service to Naamio-understandable context.
public struct BridgeResponse<R: ServiceResponse>: ServiceResponse {
    private let response: R

    public init(with response: R) {
        self.response = response
    }

    public func setHeader(key: String, value: String) {
        self.response.setHeader(key: key, value: value)
    }

    public func respond(with data: Data, code: HTTPStatusCode) {
        self.response.respond(with: data, code: code)
    }
}
