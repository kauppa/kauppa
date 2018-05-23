import Kitura
import Loki

extension Router: Routing {
    public typealias Request = RouterRequest
    public typealias Response = RouterResponse

    public func add(route url: String, method: HTTPMethod, _ handler: @escaping (Request, Response) throws -> Void) {
        let logRequest = {
            Loki.debug("Incoming \(method) request on \(url)")
        }

        switch method {
            case .get:
                self.get(url) { request, response, next in
                    logRequest()
                    try handler(request, response)
                    next()
                }
            case .post:
                self.post(url) { request, response, next in
                    logRequest()
                    try handler(request, response)
                    next()
                }
            case .put:
                self.put(url) { request, response, next in
                    logRequest()
                    try handler(request, response)
                    next()
                }
            case .patch:
                self.patch(url) { request, response, next in
                    logRequest()
                    try handler(request, response)
                    next()
                }
            case .delete:
                self.delete(url) { request, response, next in
                    logRequest()
                    try handler(request, response)
                    next()
                }
            case .options:
                self.options(url) { request, response, next in
                    logRequest()
                    try handler(request, response)
                    next()
                }
        }
    }
}
