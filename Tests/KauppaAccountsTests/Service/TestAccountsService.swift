import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaAccountsRepository
@testable import KauppaAccountsService

class TestAccountsService: XCTestCase {

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

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Test that service can create an account. E-mail and name is required for validation
    func testAccountCreation() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        var accountData = Account()
        accountData.name = "bobby"
        accountData.emails.insert(Email("abc@xyz.com"))
        let account = try! service.createAccount(with: accountData)
        XCTAssertFalse(account.emails[0]!.isVerified)
        XCTAssertFalse(account.isVerified)
    }

    /// Test that service should reject accounts if the email already exists.
    func testExistingAccount() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        var accountData = Account()
        accountData.name = "bobby"
        accountData.emails.insert(Email("abc@xyz.com"))
        let _ = try! service.createAccount(with: accountData)

        do {    // should fail because it has the same email
            let _ = try service.createAccount(with: accountData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .accountExists)
        }
    }

    /// Test that service should validate emails while creating an account.
    func testInvalidEmail() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        var accountData = Account()
        accountData.name = "bobby"
        accountData.emails.insert(Email("f/oo@xyz.com"))    // invalid email
        do {
            let _ = try service.createAccount(with: accountData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidAccountEmail)
        }

        accountData.emails = ArraySet([])       // no email
        do {
            let _ = try service.createAccount(with: accountData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.accountEmailRequired)
        }
    }

    /// Test that service should check for names with empty strings.
    func testInvalidName() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        let accountData = Account()     // name is empty
        do {
            let _ = try service.createAccount(with: accountData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidAccountName)
        }
    }

    /// Test that service should successfully delete account (if it exists)
    func testAccountDeletion() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        var accountData = Account()
        accountData.emails.insert(Email("abc@xyz.com"))
        accountData.name = "bobby"
        let data = try! service.createAccount(with: accountData)
        try! service.deleteAccount(for: data.id!)
    }

    /// Test that service should support removing individual account properties.
    // (removing address at a particular index, removing phone, etc.)
    func testPropertyRemoval() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        var accountData = Account()
        accountData.name = "bobby"
        accountData.emails = ArraySet([Email("abc@xyz.com"), Email("def@xyz.com")])
        accountData.phoneNumbers = ArraySet([Phone("<something>")])
        let address = Address(firstName: "burn", lastName: nil, line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: "home")
        accountData.address = [address]
        let account = try! service.createAccount(with: accountData)
        // check that phone, emails and address exists in returned data
        XCTAssertNotNil(account.phoneNumbers)
        XCTAssertEqual(account.phoneNumbers!.inner, [Phone("<something>")])
        XCTAssertEqual(account.emails.inner, [Email("abc@xyz.com"), Email("def@xyz.com")])
        XCTAssertNotNil(account.address)
        XCTAssertEqual(account.address!, [address])

        var patch = AccountPropertyDeletionPatch()
        patch.removePhoneAt = 0     // remove phone value
        patch.removeAddressAt = 0   // remove address at zero'th index
        var newData = try! service.deleteAccountProperty(from: account.id!, using: patch)
        XCTAssertTrue(newData.phoneNumbers!.isEmpty)
        XCTAssertEqual(newData.address!, [])

        patch.removeEmailAt = 0     // try to remove the email
        newData = try! service.deleteAccountProperty(from: account.id!, using: patch)
        XCTAssertEqual(newData.emails.inner, [Email("def@xyz.com")])

        do {    // try removing the last email
            let _ = try service.deleteAccountProperty(from: account.id!, using: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .accountEmailRequired)
        }
    }

    /// Test that service should support adding individual properties (like address).
    func testPropertyAddition() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        var accountData = Account()
        accountData.name = "bobby"
        accountData.emails.insert(Email("abc@xyz.com"))
        let account = try! service.createAccount(with: accountData)
        XCTAssertNil(account.address)   // no addresses

        var patch = AccountPropertyAdditionPatch()
        let address = Address(firstName: "apple", lastName: nil, line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: "home")
        patch.address = address
        var newData = try! service.addAccountProperty(to: account.id!, using: patch)
        XCTAssertEqual(newData.address!, [address])     // address has been added to account

        patch = AccountPropertyAdditionPatch()
        patch.email = Email("def@xyz.com")
        newData = try! service.addAccountProperty(to: account.id!, using: patch)
        XCTAssertEqual(newData.emails.inner, [Email("abc@xyz.com"), Email("def@xyz.com")])

        patch.email = Email("booya!@xyz.com")   // invalid email
        do {
            let _ = try service.addAccountProperty(to: account.id!, using: patch)
            XCTFail()
        } catch let err {   // still fails
            XCTAssertEqual(err as! ServiceError, .invalidAccountEmail)
        }
    }

    /// Test that service should support patching specific account properties.
    // (like renaming, changing phone numbers, clearing address list entirely, etc.)
    func testAccountUpdate() {
        let store = TestStore()
        let repository = AccountsRepository(with: store)
        let service = AccountsService(with: repository)
        var accountData = Account()
        accountData.name = "bobby"
        accountData.emails.insert(Email("abc@xyz.com"))
        let address = Address(firstName: "squishy", lastName: nil, line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: "home")
        accountData.address = [address]
        let account = try! service.createAccount(with: accountData)
        XCTAssertEqual(account.name, "bobby")
        XCTAssertEqual(account.emails.inner, [Email("abc@xyz.com")])
        XCTAssertEqual(account.phoneNumbers!.inner, [])
        XCTAssertEqual(account.createdOn, account.updatedAt)
        XCTAssertNotNil(account.address)
        XCTAssertEqual(account.address!.count, 1)

        var patch = AccountPatch()
        patch.name = "shelby"
        let update1 = try! service.updateAccount(for: account.id!, with: patch)
        XCTAssertEqual(update1.name, "shelby")      // name change
        XCTAssertTrue(update1.createdOn != update1.updatedAt)   // times have changed

        patch.phoneNumbers = ArraySet([Phone("12345")])
        let update2 = try! service.updateAccount(for: account.id!, with: patch)
        XCTAssertEqual(update2.phoneNumbers!.inner, [Phone("12345")])

        patch.address = []      // Clear the address list
        let update3 = try! service.updateAccount(for: account.id!, with: patch)
        XCTAssertTrue(update3.address!.isEmpty)

        patch.emails = ArraySet()       // try and clear the emails
        do {
            let _ = try service.updateAccount(for: account.id!, with: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .accountEmailRequired)
        }

        patch.name = ""
        do {
            let _ = try service.updateAccount(for: account.id!, with: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidAccountName)
        }
    }
}
