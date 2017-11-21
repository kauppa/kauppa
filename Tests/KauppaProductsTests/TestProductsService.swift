import Dispatch
import Kitura
import XCTest

@testable import KauppaProducts

class TestProductsService: XCTestCase {

    static var allTests: [(String, (TestProductsService) -> () throws -> Void)] {
        return [
            ("Test Products Service Ping", testServicePing),
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
