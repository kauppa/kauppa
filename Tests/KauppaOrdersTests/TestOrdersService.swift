import Dispatch
import Kitura
import XCTest

@testable import KauppaCore

class TestOrdersService: XCTestCase {

    static var allTests: [(String, (TestOrdersService) -> () throws -> Void)] {
        return [
            ("Test Orders Service Ping", testServicePing),
        ]
    }

    override func setUp() {
        super.setUp()

        DispatchQueue(label: "Request queue").async() {
            Kitura.run()
        }
    }

    override func tearDown() {
        super.tearDown()

        Kitura.stop()
    }

    func testServicePing() {
        let registration = expectation(description: "Service pinged")

        registration.fulfill()

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
