import XCTest

import KauppaCore
@testable import KauppaNaamioModel
@testable import KauppaNaamioService

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

class TestNaamioBridgeService: XCTestCase {
    static var allTests: [(String, (TestNaamioBridgeService) -> () throws -> Void)] {
        return [
            ("Test service initialization", testBridgeInit)
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test that the bridge service properly initializes and is able to add routes.
    func testBridgeInit() {
        let router = SampleRouter<String, String>()     // assume this is a third party router.

        let bridge = NaamioClientBridge(for: router)
        XCTAssertTrue(bridge.routes.isEmpty)
        bridge.add(route: TestRoute.foo) { req, resp in
            //
        }

        bridge.add(route: TestRoute.bar) { req, resp in
            //
        }

        XCTAssertEqual(bridge.routes.count, 2)      // handlers have been added.
    }
}
