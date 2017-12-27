import Kitura

extension Router: Routing {
    public typealias Request = RouterRequest
    public typealias Response = RouterResponse

    public func add<R>(route repr: R, _ handler: @escaping (Request, Response) throws -> Void)
        where R: RouteRepresentable
    {
        let route = repr.route
        switch route.method {
            case .get:
                self.get(route.url) { request, response, _ in
                    try handler(request, response)
                }
            case .post:
                self.post(route.url) { request, response, _ in
                    try handler(request, response)
                }
            case .put:
                self.put(route.url) { request, response, _ in
                    try handler(request, response)
                }
            case .patch:
                self.patch(route.url) { request, response, _ in
                    try handler(request, response)
                }
            case .delete:
                self.delete(route.url) { request, response, _ in
                    try handler(request, response)
                }
        }
    }
}
