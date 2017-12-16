/// Router for individual services of Kauppa.
///
/// The `Routing` protocol is usually implemented for a third-party router. But, that router
/// (by itself) should not be used across Kauppa's service-specific routers, because this exposes
/// the actual router's public resources, and it also results in tight coupling (because request and
/// response types are specific to routers, and service routers need to alias these).
///
/// To avoid this nightmare, we use this class - which acts as an abstraction over the router.
/// Service-specific routers extend from this class and can use only the publicly exposed resources.
open class ServiceRouter<R: Routing>: Routing {
    public typealias Response = R.Response
    public typealias Request = R.Request

    private let router: R

    /// Initialize the router for this service. Note that this also initializes the routes
    /// necessary for the service.
    public init(with router: R) {
        self.router = router
        self.initializeRoutes()
    }

    /// Stub. Child classes should override this function with their own set of routes.
    open func initializeRoutes() {}

    /// This is just a wrapper.
    public func add(route: Route, _ handler: @escaping (Request, Response) -> Void) {
        self.router.add(route: route, handler)
    }
}
