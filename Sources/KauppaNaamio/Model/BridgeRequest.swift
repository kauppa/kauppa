import KauppaCore

/// Wrapper object around the request responsible for getting the necessary data
/// from Naamio into a Kauppa service understandable format.
public struct BridgeRequest<R: ServiceRequest>: ServiceRequest {
    private let request: R

    public init(with request: R) {
        self.request = request
    }

    public func getHeader(for key: String) -> String? {
        return self.request.getHeader(for: key)
    }

    public func getParameter<T: StringParsable>(for key: String) -> T? {
        return self.getParameter(for: key)
    }

    public func getJSON<T: Mappable>() -> T? {
        return self.getJSON()
    }
}
