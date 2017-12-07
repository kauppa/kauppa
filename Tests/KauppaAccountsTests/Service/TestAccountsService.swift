import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaAccountsRepository
@testable import KauppaAccountsService

class TestAccountsService: XCTestCase {

    // MARK: - Static

    static var allTests: [(String, (TestAccountsService) -> () throws -> Void)] {
        return [
            ("Test account creation", testAccountCreation),
            ("Test existing account", testExistingAccount),
            ("Test invalid email", testInvalidEmail),
            ("Test account deletion", testAccountDeletion),
            ("Test removing properties", testPropertyRemoval),
            ("Test property addition", testPropertyAddition),
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

    func testAccountDeletion() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.email = "abc@xyz.com"
        let data = try! service.createAccount(withData: accountData)
        let result: ()? = try? service.deleteAccount(id: data.id)
        XCTAssertNotNil(result)     // deletion succeeded
    }

    func testPropertyRemoval() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.email = "abc@xyz.com"
        accountData.phone = "<something>"
        let address = Address(line1: "", line2: "", city: "", country: "", code: 0, kind: .home)
        let _ = accountData.address.insert(address)
        let account = try! service.createAccount(withData: accountData)
        // check that phone and address exists in returned data
        XCTAssertNotNil(account.data.phone)
        XCTAssertEqual(account.data.address.inner, [address])

        var patch = AccountPropertyDeletionPatch()
        patch.removePhone = true    // remove phone value
        patch.removeAddressAt = 0   // remove address at zero'th index
        let newData = try! service.deleteAccountProperty(id: account.id, data: patch)
        XCTAssertNil(newData.data.phone)
        XCTAssertEqual(newData.data.address.inner, [])
    }

    func testPropertyAddition() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.email = "abc@xyz.com"
        let account = try! service.createAccount(withData: accountData)
        XCTAssertEqual(account.data.address.inner, [])      // address list is empty

        var patch = AccountPropertyAdditionPatch()
        let address = Address(line1: "", line2: "", city: "", country: "", code: 0, kind: .home)
        patch.address = address
        let newData = try! service.addAccountProperty(id: account.id, data: patch)
        XCTAssertEqual(newData.data.address.inner, [address])   // address has been added to account
    }
}
