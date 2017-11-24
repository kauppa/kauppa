import Foundation
import XCTest

@testable import KauppaAccountsService

class TestAccountsService: XCTestCase {

    // MARK: - Static

    static var allTests: [(String, (TestAccountsService) -> () throws -> Void)] {
        return [
            //("Test account creation", testAccountCreation),
        ]
    }

    // MARK: - Instance

    override func setUp() {
        super.setUp()

        let router = AccountsRouter()
    }

    override func tearDown() {
        super.tearDown()
    }
}