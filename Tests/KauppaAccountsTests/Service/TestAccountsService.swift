import Foundation
import XCTest

@testable import KauppaAccountsModel
@testable import KauppaAccountsRepository
@testable import KauppaAccountsService

class TestAccountsService: XCTestCase {

    // MARK: - Static

    static var allTests: [(String, (TestAccountsService) -> () throws -> Void)] {
        return [
            ("Test account creation", testAccountCreation),
            ("Test existing account", testExistingAccount),
            ("Test invalid email", testInvalidEmail)
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
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.email = "abc@xyz.com"
        let data = try? service.createAccount(withData: accountData)
        XCTAssertNotNil(data)       // account data should exist
    }

    func testExistingAccount() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.email = "abc@xyz.com"
        let _ = try! service.createAccount(withData: accountData)    // success
        // This should fail because it has the same email
        let result = try? service.createAccount(withData: accountData)
        XCTAssertNil(result)
    }

    func testInvalidEmail() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.email = "f/oo@xyz.com"      // invalid email
        let result = try? service.createAccount(withData: accountData)
        XCTAssertNil(result)
    }
}
