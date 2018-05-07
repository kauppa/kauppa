import Foundation

/// Router for individual services of Kauppa.
///
/// The `Routing` protocol is usually implemented for a third-party router. But, that router
/// (by itself) should not be used across Kauppa's service-specific routers, because this exposes
/// the actual router's public resources, and it also results in tight coupling (because request and
/// response types are specific to routers, and service routers need to alias these).
///
/// To avoid this nightmare, we use this class - which acts as an abstraction over the router.
/// Service-specific routers extend from this class and can use only the publicly exposed resources.
open class ServiceRouter<R: Routing, U: RouteRepresentable> {
    public typealias Request = R.Request
    public typealias Response = R.Response

    private let router: R

    private var routeMethods = [String: [HTTPMethod]]()

    /// Initialize the router for this service. Note that this also initializes the routes
    /// necessary for the service by calling the overridable method `initializeRoutes`.
    /// Finally, this adds handlers for `OPTIONS` method in the added routes.
    public init(with router: R) {
        self.router = router
        self.initializeRoutes()
        self.addOptionsHandlers()
    }

    /// Stub. Child classes should override this function with their own set of routes.
    open func initializeRoutes() {}

    /// Wrapper for the actual route addition. Although this has the same signature as
    /// `add` method from `Routing` protocol, this  converts the throwable closure
    /// into a non-throwable one, by catching the error and encoding it appropriately
    /// as a `ServiceStatusMessage` object with the error code.
    ///
    /// - Parameters:
    ///   - route: A variant of `RouteRepresentable` object used for instantiating this class.
    ///   - The closure which gets the associated request and response object from the service call.
    public func add(route repr: U, _ handler: @escaping (Request, Response) throws -> Void) {
        let route = repr.route
        if routeMethods[route.url] != nil {
            routeMethods[route.url]!.append(route.method)
        } else {
            routeMethods[route.url] = [route.method]
        }

        self.router.add(route: route.url, method: route.method) { request, response in
            do {
                try handler(request, response)
            } catch let error as ServiceError {
                let status = ServiceStatusMessage(error: error)
                try response.respondJSON(with: status, code: error.statusCode)
            } catch {
                let error = ServiceError.unknownError
                // TODO: Log unknown error
                let status = ServiceStatusMessage(error: error)
                try response.respondJSON(with: status, code: error.statusCode)
            }
        }
    }

    /// Iterates over all the defined routes, gathers their methods and mounts handlers
    /// for `OPTIONS` method in those routes.
    private func addOptionsHandlers() {
        for (url, methods) in routeMethods {
            if methods.contains(.options) {
                // Ignore if there's already an OPTIONS handler for this route.
                continue
            }

            let methodDescriptions = methods.map { $0.description }
            let headerValue = methodDescriptions.joined(separator: ", ")

            self.router.add(route: url, method: .options) { request, response in
                // FIXME: Remove this!
                response.setHeader(key: "Access-Control-Allow-Origin", value: "*")
                response.setHeader(key: "Access-Control-Allow-Methods", value: headerValue)

                response.setHeader(key: "Allow", value: headerValue)
                response.respond(with: Data(), code: .ok)
            }
        }
    }
}
