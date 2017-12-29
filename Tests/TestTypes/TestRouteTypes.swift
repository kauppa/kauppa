import Foundation

import KauppaCore

extension String: Error {}

/// Request object conforming to `ServiceRequest` used throughout testing
struct TestRequest<J: Mappable>: ServiceRequest {
    var headers = [String: String]()
    var parameters = [String: String]()
    var json: J? = nil

    public func getHeader(for key: String) -> String? {
        return headers[key]
    }

    public func getParameter<T: StringParsable>(for key: String) -> T? {
        if let value = parameters[key] {
            return value.parse()
        }

        return nil
    }

    public func getJSON<T: Mappable>() -> T? {
        if let value = json {
            return value as? T
        } else {
            return nil
        }
    }
}

typealias ResponseCallback = (Data, HTTPStatusCode) -> Void
typealias HeaderCallback = (String, String) -> Void

/// Response object conforming to `ServiceResponse` used throughout testing
struct TestResponse: ServiceResponse {
    var callback: ResponseCallback? = nil
    var headerCallback: HeaderCallback? = nil

    public func setHeader(key: String, value: String) {
        if let callback = headerCallback {
            callback(key, value)
        }
    }

    public func respond(with data: Data, code: HTTPStatusCode) {
        if let callback = callback {
            callback(data, code)
        }
    }
}

/// Router object conforming to `Routing` used throughout testing
class SampleRouter<Req: Mappable>: Routing {
    typealias Request = TestRequest<Req>
    typealias Response = TestResponse

    var routes = [Route: (Request, Response) throws -> Void]()

    public func add<R>(route repr: R, _ handler: @escaping (Request, Response) throws -> Void)
        where R: RouteRepresentable
    {
        routes[repr.route] = handler
    }
}

enum TestRoute: UInt8 {
    case foo
    case bar
    case baz
    case boo
}

extension TestRoute: RouteRepresentable {
    public var route: Route {
        switch self {
            case .foo:
                return Route(url: "/foo", method: .get)
            case .bar:
                return Route(url: "/bar", method: .post)
            case .baz:
                return Route(url: "/baz", method: .put)
            case .boo:
                return Route(url: "/:id/:booya/", method: .delete)
        }
    }
}
