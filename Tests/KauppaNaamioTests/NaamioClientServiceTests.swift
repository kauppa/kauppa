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
        // FIXME: Revisit the bridge implementation.
    }
}
