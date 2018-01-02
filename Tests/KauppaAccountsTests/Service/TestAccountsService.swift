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
            ("Test invalid name", testInvalidName),
            ("Test account deletion", testAccountDeletion),
            ("Test removing properties", testPropertyRemoval),
            ("Test property addition", testPropertyAddition),
            ("Test account update", testAccountUpdate),
        ]
    }

    // MARK: - Instance

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Service can create an account. E-mail and name is required for validation
    func testAccountCreation() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.emails.insert("abc@xyz.com")
        let _ = try! service.createAccount(withData: accountData)   // account data should exist
    }

    // Service should reject accounts if the email already exists.
    func testExistingAccount() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.emails.insert("abc@xyz.com")
        let _ = try! service.createAccount(withData: accountData)

        do {    // should fail because it has the same email
            let _ = try service.createAccount(withData: accountData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, .accountExists)
        }
    }

    // Service should validate emails while creating an account.
    func testInvalidEmail() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.emails.insert("f/oo@xyz.com")       // invalid email
        do {
            let _ = try service.createAccount(withData: accountData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, AccountsError.invalidEmail)
        }

        accountData.emails = ArraySet([])       // no email
        do {
            let _ = try service.createAccount(withData: accountData)
            XCTFail()
        } catch let err {
            XCTAssertTrue(err as! AccountsError == AccountsError.emailRequired)
        }
    }

    // Service should check for names with empty strings.
    func testInvalidName() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        let accountData = AccountData()     // name is empty
        do {
            let _ = try service.createAccount(withData: accountData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, AccountsError.invalidName)
        }
    }

    // Service should successfully delete account (if it exists)
    func testAccountDeletion() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.emails.insert("abc@xyz.com")
        accountData.name = "bobby"
        let data = try! service.createAccount(withData: accountData)
        try! service.deleteAccount(id: data.id)
    }

    // Service should support removing individual account properties.
    // (removing address at a particular index, removing phone, etc.)
    func testPropertyRemoval() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.emails = ArraySet(["abc@xyz.com", "def@xyz.com"])
        accountData.phone = "<something>"
        let address = Address(line1: "foo", line2: "bar", city: "baz", country: "bleh", code: "666", kind: .home)
        accountData.address.insert(address)
        let account = try! service.createAccount(withData: accountData)
        // check that phone and address exists in returned data
        XCTAssertNotNil(account.data.phone)
        XCTAssertEqual(account.data.address.inner, [address])

        var patch = AccountPropertyDeletionPatch()
        patch.removePhone = true    // remove phone value
        patch.removeAddressAt = 0   // remove address at zero'th index
        var newData = try! service.deleteAccountProperty(id: account.id, data: patch)
        XCTAssertNil(newData.data.phone)
        XCTAssertEqual(newData.data.address.inner, [])

        patch.removeEmailAt = 0     // try to remove the email
        newData = try! service.deleteAccountProperty(id: account.id, data: patch)
        XCTAssertEqual(newData.data.emails.inner, ["def@xyz.com"])

        do {    // try removing the last email
            let _ = try service.deleteAccountProperty(id: account.id, data: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, .emailRequired)
        }
    }

    // Service should support adding individual properties (like address).
    func testPropertyAddition() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.emails.insert("abc@xyz.com")
        let account = try! service.createAccount(withData: accountData)
        XCTAssertEqual(account.data.address.inner, [])      // address list is empty

        var patch = AccountPropertyAdditionPatch()
        let address = Address(line1: "foo", line2: "bar", city: "baz", country: "bleh", code: "666", kind: .home)
        patch.address = address
        var newData = try! service.addAccountProperty(id: account.id, data: patch)
        XCTAssertEqual(newData.data.address.inner, [address])   // address has been added to account

        patch = AccountPropertyAdditionPatch()
        patch.email = "def@xyz.com"
        newData = try! service.addAccountProperty(id: account.id, data: patch)
        XCTAssertEqual(newData.data.emails.inner, ["abc@xyz.com", "def@xyz.com"])

        patch.email = "booya!@xyz.com"  // invalid email
        do {
            let _ = try service.addAccountProperty(id: account.id, data: patch)
            XCTFail()
        } catch let err {   // still fails
            XCTAssertEqual(err as! AccountsError, .invalidEmail)
        }
    }

    // Service should support patching specific account properties.
    // (like renaming, changing phone numbers, clearing address list entirely, etc.)
    func testAccountUpdate() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.emails.insert("abc@xyz.com")
        let address = Address(line1: "foo", line2: "bar", city: "baz", country: "bleh", code: "666", kind: .home)
        accountData.address.insert(address)
        let account = try! service.createAccount(withData: accountData)
        XCTAssertEqual(account.data.name, "bobby")
        XCTAssertEqual(account.data.emails.inner, ["abc@xyz.com"])
        XCTAssertNil(account.data.phone)
        XCTAssertEqual(account.createdOn, account.updatedAt)
        XCTAssertEqual(account.data.address.count, 1)

        var patch = AccountPatch()
        patch.name = "shelby"
        let update1 = try! service.updateAccount(id: account.id, data: patch)
        XCTAssertEqual(update1.data.name, "shelby")     // name change
        XCTAssertTrue(update1.createdOn != update1.updatedAt)   // times have changed

        patch.phone = "12345"   // FIXME: Check phone number in some mysterious way
        let update2 = try! service.updateAccount(id: account.id, data: patch)
        XCTAssertEqual(update2.data.phone, "12345")

        patch.address = ArraySet()      // Clear the address list
        let update3 = try! service.updateAccount(id: account.id, data: patch)
        XCTAssertTrue(update3.data.address.isEmpty)

        patch.emails = ArraySet()       // try and clear the emails
        do {
            let _ = try service.updateAccount(id: account.id, data: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, .emailRequired)
        }

        patch.name = ""
        do {
            let _ = try service.updateAccount(id: account.id, data: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, AccountsError.invalidName)
        }
    }
}
