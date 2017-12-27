import Foundation

import KauppaCore

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

typealias ResponseCallback<T> = (T, HTTPStatusCode) -> Void

/// Response object conforming to `ServiceResponse` used throughout testing
struct TestResponse<J: Mappable>: ServiceResponse {
    var callback: ResponseCallback<J>? = nil

    public func respond(with data: Data, code: HTTPStatusCode) {
        if let callback = callback {
            let object = try! JSONDecoder().decode(J.self, from: data)
            callback(object, code)
        }
    }
}

/// Router object conforming to `Routing` used throughout testing
class SampleRouter<Req: Mappable, Resp: Mappable>: Routing {
    typealias Request = TestRequest<Req>
    typealias Response = TestResponse<Resp>

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
}

extension TestRoute: RouteRepresentable {
    public var route: Route {
        switch self {
            case .foo:
                return Route(url: "/foo", method: .get)
            case .bar:
                return Route(url: "/bar", method: .post)
        }
    }
}
