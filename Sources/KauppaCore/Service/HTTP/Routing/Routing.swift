/// Routing protocol to be implemented by router objects. It provides the rules for
/// routing mechanisms over HTTP.
public protocol Routing {
    /// The request object provided by this router.
    associatedtype Request: ServiceRequest
    /// The response object provided by this router.
    associatedtype Response: ServiceResponse

    /// Add a handler for the given URL and method.
    ///
    /// - Parameters:
    ///   - route: The route URL to be handled.
    ///   - method: The method for this route.
    ///   - The closure which gets the associated request and response object from the service call.
    func add(route url: String, method: HTTPMethod, _ handler: @escaping (Request, Response) throws -> Void)
}
