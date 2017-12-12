import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaCartModel
@testable import KauppaCartRepository

class TestCartRepository: XCTestCase {
    static var allTests: [(String, (TestCartRepository) -> () throws -> Void)] {
        return [
            ("Test cart creation", testCartCreation),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCartCreation() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let cart = CartData()
        // These two timestamps should be the same in creation
        let data = try! repository.createCart(data: cart)
        XCTAssertEqual(data.createdOn, data.updatedAt)
        XCTAssertTrue(store.createCalled)       // store has been called for creation
        XCTAssertNotNil(repository.carts[data.id])      // repository has the cart
    }
}
