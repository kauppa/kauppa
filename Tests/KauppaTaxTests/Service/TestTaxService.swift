import XCTest

@testable import KauppaTaxService

class TestTaxService: XCTestCase {

    static var allTests: [(String, (TestTaxService) -> () throws -> Void)] {
        return [
            ("Test Tax Service Ping", testServicePing),
        ]
    }

    var taxService: TaxService?

    override func setUp() {
        taxService = TaxService()

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
