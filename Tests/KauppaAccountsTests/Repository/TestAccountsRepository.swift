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

    // Test the repository for account creation. It takes care of the timestamps and is responsible
    // for caching the account, and calling the store.
    func testAccountCreation() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let accountData = AccountData()
        let data = try? repository.createAccount(with: accountData)
        XCTAssertNotNil(data)
        // These two timestamps should be the same in creation
        XCTAssertEqual(data!.createdOn, data!.updatedAt)
        XCTAssertTrue(store.createCalled)   // store has been called for creation
        XCTAssertNotNil(repository.accounts[data!.id])  // repository now has account data
    }

    // Test the repository for account deletion. Deletion should remove the item from the cache
    // and it should call the store.
    func testAccountDeletion() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let accountData = AccountData()

        let data = try! repository.createAccount(with: accountData)
        let result: ()? = try? repository.deleteAccount(for: data.id)
        XCTAssertNotNil(result)
        XCTAssertTrue(repository.accounts.isEmpty)      // repository shouldn't have the account
        XCTAssertTrue(store.deleteCalled)       // delete should've been called in store (by repository)
    }

    // Test the repository for account update. It should update the item in the cache and the store.
    func testAccountUpdate() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        var accountData = AccountData()
        let data = try! repository.createAccount(with: accountData)
        XCTAssertEqual(data.createdOn, data.updatedAt)
        accountData.name = "FooBar"
        let updatedAccount = try! repository.updateAccount(for: data.id, with: accountData)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertEqual(updatedAccount.data.name, "FooBar")
        XCTAssertTrue(store.updateCalled)
    }

    // Test the repository for proper store calls. If the item doesn't exist in the cache, then
    // it should get from the store and cache it. Re-getting the item shouldn't call the store.
    func testStoreCalls() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let accountData = AccountData()
        let data = try! repository.createAccount(with: accountData)
        repository.accounts = [:]       // clear the repository
        let _ = try? repository.getAccount(for: data.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we've never called the store
        let _ = try? repository.getAccount(for: data.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
