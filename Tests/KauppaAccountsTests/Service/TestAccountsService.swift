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

    func testAccountCreation() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.email = "abc@xyz.com"
        let data = try? service.createAccount(withData: accountData)
        XCTAssertNotNil(data)       // account data should exist
    }

    func testExistingAccount() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.email = "abc@xyz.com"
        let _ = try! service.createAccount(withData: accountData)    // success

        do {
            let _ = try service.createAccount(withData: accountData)
            XCTFail()
        } catch let err {   // should fail because it has the same email
            XCTAssertTrue(err as! AccountsError == AccountsError.accountExists)
        }
    }

    func testInvalidEmail() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.email = "f/oo@xyz.com"      // invalid email
        do {
            let _ = try service.createAccount(withData: accountData)
            XCTFail()
        } catch let err {   // should fail because it has the same email
            XCTAssertTrue(err as! AccountsError == AccountsError.invalidEmail)
        }
    }

    func testInvalidName() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        let accountData = AccountData()     // name is empty
        do {
            let _ = try service.createAccount(withData: accountData)
            XCTFail()
        } catch let err {   // should fail because it has the same email
            XCTAssertTrue(err as! AccountsError == AccountsError.invalidName)
        }
    }

    func testAccountDeletion() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.email = "abc@xyz.com"
        accountData.name = "bobby"
        let data = try! service.createAccount(withData: accountData)
        let result: ()? = try? service.deleteAccount(id: data.id)
        XCTAssertNotNil(result)     // deletion succeeded
    }

    func testPropertyRemoval() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
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
        accountData.name = "bobby"
        accountData.email = "abc@xyz.com"
        let account = try! service.createAccount(withData: accountData)
        XCTAssertEqual(account.data.address.inner, [])      // address list is empty

        var patch = AccountPropertyAdditionPatch()
        let address = Address(line1: "", line2: "", city: "", country: "", code: 0, kind: .home)
        patch.address = address
        let newData = try! service.addAccountProperty(id: account.id, data: patch)
        XCTAssertEqual(newData.data.address.inner, [address])   // address has been added to account
    }

    func testAccountUpdate() {
        let store = TestStore()
        let repository = AccountsRepository(withStore: store)
        let service = AccountsService(withRepository: repository)
        var accountData = AccountData()
        accountData.name = "bobby"
        accountData.email = "abc@xyz.com"
        let _ = accountData.address.insert(Address(line1: "", line2: "", city: "", country: "", code: 0, kind: .home))
        let account = try! service.createAccount(withData: accountData)
        XCTAssertEqual(account.data.name, "bobby")
        XCTAssertEqual(account.data.email, "abc@xyz.com")
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

        patch.name = ""
        do {
            let _ = try service.updateAccount(id: account.id, data: patch)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, AccountsError.invalidName)
        }
    }
}
