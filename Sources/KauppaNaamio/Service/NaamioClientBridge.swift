import KauppaCore
import KauppaNaamioModel

// FIXME: Revisit this.

/// Bridging service for registering and communicating with Naamio.
///
/// The `Routing` protocol is implemented for a third-party router. The bridge (being a proxy),
/// wraps around the router and adds routes by modifying the handlers (see `add` method).
public class NaamioClientBridge<R: Routing>: Routing {
    public typealias Request = BridgeRequest<R.Request>
    public typealias Response = BridgeResponse<R.Response>

    typealias ActualRequest = R.Request
    typealias ActualResponse = R.Response

    private let router: R

    /// Collection of routes that have been initialized in this bridge so far.
    public private(set) var routes = [Route: (ActualRequest, ActualResponse) throws -> Void]()

    public init(for router: R) {
        self.router = router
        // TODO: Initialize the client for Naamio
    }

    /// This function is responsible for changing the handlers. For an incoming request,
    /// it translates Naamio's data into something that's understandable by the services.
    /// For an outgoing response, this translates the JSON data into Naamio-understandable
    /// context. This is taken care of by `BridgeRequest` and `BridgeResponse` wrapper objects.
    public func add(route url: String, method: HTTPMethod, _ handler: @escaping (Request, Response) throws -> Void) {
        let new_handler: (ActualRequest, ActualResponse) throws -> Void = { req, resp in
            let request = BridgeRequest(with: req)
            let response = BridgeResponse(with: resp)
            try handler(request, response)
        }

        let route = Route(url: url, method: method)
        self.routes[route] = new_handler
        self.router.add(route: route.url, method: method, new_handler)
    }

    /* MARK: Naamio-specific methods */

    /// This service has now been initialized with all the routes. It's now time
    /// to talk to Naamio about this.
    public func registerRoutes() {
        // TODO: Register the routes in this service with Naamio.
    }
}
