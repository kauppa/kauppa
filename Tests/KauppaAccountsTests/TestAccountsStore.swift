import Foundation
import XCTest

@testable import KauppaCore

class TestAccountsStore: XCTestCase {

    var store = MemoryStore()

    static var allTests: [(String, (TestAccountsStore) -> () throws -> Void)] {
        return [
            ("AccountCreation", testAccountCreation),
        ]
    }

    override func setUp() {
        store = MemoryStore()

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func createAccountData(name: String = "foobar",
                           email: String = "foo@bar.com") -> AccountData {
        let string = """
            {
                "name": "\(name)",
                "email": "\(email)",
                "phone": "+0 0000000",
                "address": [],
                "cards": []
            }
        """

        return decodeJsonFrom(string)
    }

    func decodeJsonFrom<T>(_ string: String) -> T where T: Decodable {
        let jsonData = string.data(using: .utf8)!
        let data = try! JSONDecoder().decode(T.self, from: jsonData)
        return data
    }

    func testAccountCreation() {
        let creation = expectation(description: "Account created")
        let account = self.createAccountData()
        let data = store.createAccount(data: account)!
        let id = Array(self.store.accounts.keys)[0]
        XCTAssertEqual(id, data.id)
        let email = Array(self.store.emailIds.keys)[0]
        XCTAssertEqual(email, account.email)
        creation.fulfill()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
}
