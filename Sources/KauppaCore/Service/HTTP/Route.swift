/// Represents a service route. An incoming request that matches with a
/// registered route and method will be associated with a service call.
public struct Route {
    /// URI of this route.
    public let uri: String
    /// Methods allowed for this route.
    public var method: HttpMethod

    public init(uri: String, method: HttpMethod) {
        self.uri = uri
        self.method = method
    }
}
