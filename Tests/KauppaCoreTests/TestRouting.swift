import XCTest

@testable import KauppaCore
@testable import TestTypes

class TestServiceRouter<R: Routing>: ServiceRouter<R> {
    override func initializeRoutes() {
        add(route: TestRoute.foo) { req, resp in
            //
        }

        add(route: TestRoute.bar) { req, resp in
            //
        }
    }
}

class TestRouting: XCTestCase {
    static var allTests: [(String, (TestRouting) -> () throws -> Void)] {
        return [
            ("Test route representable object", testRouteRepresentable),
            ("Test route initialization in service router", testServiceRouterInit),
        ]
    }

    // Test that route representable types can be queried for all routes.
    func testRouteRepresentable() {
        let routes = TestRoute.allRoutes
        XCTAssertEqual(routes.count, 2)
        XCTAssertEqual(routes[0].url, "/foo")
        XCTAssertEqual(routes[0].method, .get)
        XCTAssertEqual(routes[1].url, "/bar")
        XCTAssertEqual(routes[1].method, .post)
    }

    // Test that initializing a service router adds the initial set of routes.
    func testServiceRouterInit() {
        let router = SampleRouter<String, String>()
        let _ = TestServiceRouter(with: router)
        XCTAssertEqual(router.routes.count, 2)
    }
}
