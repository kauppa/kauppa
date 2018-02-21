import Kitura

extension Router: Routing {
    public typealias Request = RouterRequest
    public typealias Response = RouterResponse

    public func add(route url: String, method: HTTPMethod, _ handler: @escaping (Request, Response) throws -> Void) {
        switch method {
            case .get:
                self.get(url) { request, response, _ in
                    try handler(request, response)
                }
            case .post:
                self.post(url) { request, response, _ in
                    try handler(request, response)
                }
            case .put:
                self.put(url) { request, response, _ in
                    try handler(request, response)
                }
            case .patch:
                self.patch(url) { request, response, _ in
                    try handler(request, response)
                }
            case .delete:
                self.delete(url) { request, response, _ in
                    try handler(request, response)
                }
            case .options:
                self.options(url) { request, response, _ in
                    try handler(request, response)
                }
        }
    }
}
