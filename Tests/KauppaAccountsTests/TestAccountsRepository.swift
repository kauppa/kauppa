import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaAccounts

class TestAccountsRepository: XCTestCase {

    // MARK: - Static

    static var allTests: [(String, (TestAccountsRepository) -> () throws -> Void)] {
        return [
            ("Test account creation", testAccountCreation),
        ]
    }

    // MARK: - Instance

    var store = AccountsRepository()

    override func setUp() {
        store = AccountsRepository()

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAccountCreation() {
        let creation = expectation(description: "Account created")
        let account = AccountData()
        let data = store.createAccount(data: account)!
        let id = Array(self.store.accounts.keys)[0]
        XCTAssertEqual(id, data.id)
        let email = "test@test.co" //TODO: Array(self.store.emailIds.keys)[0]
        XCTAssertEqual(email, account.email)
        creation.fulfill()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
