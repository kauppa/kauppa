import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaAccountsRepository

class TestAccountsRepository: XCTestCase {

    // MARK: - Static

    static var allTests: [(String, (TestAccountsRepository) -> () throws -> Void)] {
        return [
            ("Test account creation", testAccountCreation),
            ("Test account deletion", testAccountDeletion),
            ("Test account update", testAccountUpdate),
            ("Test store function calls", testStoreCalls),
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

    func testAccountDeletion() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let accountData = AccountData()

        let data = try! repository.createAccount(data: accountData)
        let result: ()? = try? repository.deleteAccount(forId: data.id)
        XCTAssertNotNil(result)
        XCTAssertTrue(repository.accounts.isEmpty)      // repository shouldn't have the account
        XCTAssertTrue(store.deleteCalled)       // delete should've been called in store (by repository)
    }

    func testAccountUpdate() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        var accountData = AccountData()
        let data = try! repository.createAccount(data: accountData)
        XCTAssertEqual(data.createdOn, data.updatedAt)
        accountData.name = "FooBar"
        let updatedAccount = try! repository.updateAccountData(forId: data.id, data: accountData)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedAccount.data.name, "FooBar")
        XCTAssertTrue(store.updateCalled)
    }

    func testStoreCalls() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let accountData = AccountData()
        let data = try! repository.createAccount(data: accountData)
        repository.accounts = [:]       // clear the repository
        let _ = try? repository.getAccount(forId: data.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we've never called the store
        let _ = try? repository.getAccount(forId: data.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
