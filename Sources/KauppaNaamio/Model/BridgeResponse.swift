import KauppaCore

/// Wrapper object around the response which is responsible for translating the
/// JSON data from the service to Naamio-understandable context.
public struct BridgeResponse<R: ServiceResponse>: ServiceResponse {
    private let response: R

    public init(with response: R) {
        self.response = response
    }

    public func respond<T: Mappable>(with data: T, code: HTTPStatusCode) {
        // TODO: Translate data to Naamio dictionary.
        self.response.respond(with: data, code: code)
    }
}
