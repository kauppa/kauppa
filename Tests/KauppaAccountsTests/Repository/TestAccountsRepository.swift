import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaAccountsRepository

class TestAccountsRepository: XCTestCase {

    // MARK: - Static

    static var allTests: [(String, (TestAccountsRepository) -> () throws -> Void)] {
        return [
            ("Test account creation", testAccountCreation)
        ]
    }

    // MARK: - Instance

    override func setUp() {

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAccountCreation() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let accountData = AccountData()
        let data = try? repository.createAccount(data: accountData)
        XCTAssertNotNil(data)
        // These two timestamps should be the same in creation
        XCTAssertEqual(data!.createdOn, data!.updatedAt)
        XCTAssertTrue(store.createCalled)   // store has been called for creation
        XCTAssertNotNil(repository.accounts[data!.id])  // repository now has account data
    }
}
