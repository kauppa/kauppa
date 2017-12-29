import XCTest

@testable import KauppaCore
@testable import TestTypes

struct DateResponse: Mappable {
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

    let date = Date()
}

class TestServiceRouter<R: Routing>: ServiceRouter<R> {
    override func initializeRoutes() {
        add(route: TestRoute.foo) { req, resp in
            resp.respondJSON(with: DateResponse(), code: .ok)
        }

        add(route: TestRoute.bar) { req, resp in
            throw ServiceError.clientHTTPData
        }

        add(route: TestRoute.baz) { req, resp in
            throw "boo"     // This should return `unknownError`
        }
    }
}

class TestRouting: XCTestCase {
    static var allTests: [(String, (TestRouting) -> () throws -> Void)] {
        return [
            ("Test route representable object", testRouteRepresentable),
            ("Test route initialization in service router", testServiceRouterInit),
            ("Test response date JSON encoding", testResponseDateEncoding),
            ("Test response service error", testResponseHandlerServiceError),
            ("Test response unhandled error", testResponseHandlerUnhandledError),
        ]
    }

    /// Test that route representable types can be queried for all routes.
    func testRouteRepresentable() {
        let routes = TestRoute.allRoutes
        XCTAssertEqual(routes.count, 4)
        XCTAssertEqual(routes[0].url, "/foo")
        XCTAssertEqual(routes[0].method, .get)
        XCTAssertEqual(routes[1].url, "/bar")
        XCTAssertEqual(routes[1].method, .post)
        XCTAssertEqual(routes[2].url, "/baz")
        XCTAssertEqual(routes[2].method, .put)
        XCTAssertEqual(routes[3].url, "/:id/:booya/")
        XCTAssertEqual(routes[3].method, .delete)
    }

    /// Test that initializing a service router adds the initial set of routes.
    func testServiceRouterInit() {
        let router = SampleRouter<String>()
        let _ = TestServiceRouter(with: router)
        XCTAssertEqual(router.routes.count, 3)
    }

    /// Test that date can be properly encoded in the expected format and content type
    /// has been set in header.
    func testResponseDateEncoding() {
        let rawRouter = SampleRouter<String>()
        let _ = TestServiceRouter(with: rawRouter)

        let req = TestRequest<String>()
        var resp = TestResponse()
        var headers = [String: String]()

        resp.headerCallback = { key, value in
            headers[key] = value
        }

        let dateDecoded = expectation(description: "Date has been decoded successfully")
        resp.callback = { data, code in
            XCTAssertEqual(code, .ok)
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateResponse.dateFormat
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let result = try? decoder.decode(DateResponse.self, from: data)
            XCTAssertNotNil(result)
            dateDecoded.fulfill()
        }

        let handler = rawRouter.routes[TestRoute.foo.route]!
        try! handler(req, resp)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }

        XCTAssertEqual(headers["Content-Type"]!, "application/json")
    }

    /// Test that the error thrown by the service is responded as a status message with an error code.
    func testResponseHandlerServiceError() {
        let rawRouter = SampleRouter<String>()
        let _ = TestServiceRouter(with: rawRouter)

        let req = TestRequest<String>()
        var resp = TestResponse()
        var headers = [String: String]()

        resp.headerCallback = { key, value in
            headers[key] = value
        }

        let statusReceived = expectation(description: "Status message has been received")
        resp.callback = { data, code in
            let status = try! JSONDecoder().decode(ServiceStatusMessage.self, from: data)
            XCTAssertEqual(status.code, ServiceError.clientHTTPData.rawValue)
            XCTAssertEqual(status.code, ServiceError.clientHTTPData.rawValue)
            statusReceived.fulfill()
        }

        let handler = rawRouter.routes[TestRoute.bar.route]!
        try! handler(req, resp)     // this shouldn't fail (because the handler has been modified)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }

        XCTAssertEqual(headers["Content-Type"]!, "application/json")
    }

    /// Test that any unhandled error is caught and returned as an unknown error from the service.
    func testResponseHandlerUnhandledError() {
        let rawRouter = SampleRouter<String>()
        let _ = TestServiceRouter(with: rawRouter)

        let req = TestRequest<String>()
        var resp = TestResponse()
        var headers = [String: String]()

        resp.headerCallback = { key, value in
            headers[key] = value
        }

        let statusReceived = expectation(description: "Status message has been received")
        resp.callback = { data, code in
            let status = try! JSONDecoder().decode(ServiceStatusMessage.self, from: data)
            XCTAssertEqual(status.code, ServiceError.unknownError.rawValue)
            statusReceived.fulfill()
        }

        let handler = rawRouter.routes[TestRoute.baz.route]!
        try! handler(req, resp)     // this shouldn't fail (because the handler has been modified)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }

        XCTAssertEqual(headers["Content-Type"]!, "application/json")
    }
}
