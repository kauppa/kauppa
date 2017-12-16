import Kitura

extension Router: Routing {
    public typealias Request = RouterRequest
    public typealias Response = RouterResponse

    public func add(route: Route, _ handler: @escaping (Request, Response) -> Void) {
        switch route.method {
            case  .Get:
                self.get(route.uri) { request, response, _ in
                    handler(request, response)
                }
            case .Post:
                self.post(route.uri) { request, response, _ in
                    handler(request, response)
                }
            case .Put:
                self.put(route.uri) { request, response, _ in
                    handler(request, response)
                }
            case .Patch:
                self.patch(route.uri) { request, response, _ in
                    handler(request, response)
                }
            case .Delete:
                self.delete(route.uri) { request, response, _ in
                    handler(request, response)
                }
        }
    }
}
