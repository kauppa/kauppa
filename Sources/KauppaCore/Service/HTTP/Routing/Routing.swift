/// Routing protocol to be implemented by router objects. It provides the rules for
/// routing mechanisms over HTTP.
public protocol Routing {
    /// The request object provided by this router.
    associatedtype Request: ServiceRequest
    /// The response object provided by this router.
    associatedtype Response: ServiceResponse

    /// Add a route to this router with the given handler.
    ///
    /// - Parameters:
    ///   - route: A `RouteRepresentable` object.
    ///   - The closure which gets the associated request and response object from the service call.
    func add<R: RouteRepresentable>(route repr: R, _ handler: @escaping (Request, Response) throws -> Void)
}
