import XCTest

@testable import KauppaCore

class TestAccountsStore: XCTestCase {

    static var allTests: [(String, (TestAccountsStore) -> () throws -> Void)] {
        return [
            ("AccountCreation", testAccountCreation),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAccountCreation() {
        //
    }
}
