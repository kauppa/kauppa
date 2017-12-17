import XCTest

import KauppaCore
@testable import TestTypes
@testable import KauppaNaamioModel
@testable import KauppaNaamioService

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
