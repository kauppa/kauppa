import XCTest

@testable import KauppaCore

class TestTaxService: XCTestCase {

    static var allTests: [(String, (TestTaxService) -> () throws -> Void)] {
        return [
            ("Test Tax Service Ping", testServicePing),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testServicePing() {
        let registration = expectation(description: "Service pinged")
        registration.fulfill()

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
