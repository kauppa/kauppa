import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaCartModel
@testable import KauppaCartRepository

class TestCartRepository: XCTestCase {
    static var allTests: [(String, (TestCartRepository) -> () throws -> Void)] {
        return [
            ("Test getting cart", testCartGet),
            ("Test updating cart", testCartUpdate),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test the repository for getting cart. A cart is always associated with an account.
    // So, the repository will create it if it doesn't exist. We avoid creating carts for random
    // UUIDs by checking with the accounts service while adding items to a cart.
    func testCartGet() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let randomId = UUID()   // assume some user with this ID
        let data = try! repository.getCart(forId: randomId)
        XCTAssertTrue(store.getCalled)  // store has been queried
        XCTAssertTrue(store.createCalled)   // new cart has been created in store
        XCTAssertTrue(data.items.isEmpty)   // no items initially
        XCTAssertEqual(data.id, randomId)   // cart ID is the same as account ID
        XCTAssertNotNil(repository.carts[data.id])      // repository has the cart
    }

    // Test for updating repository which should also update the store.
    func testCartUpdate() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let randomId = UUID()   // assume some user with this ID
        var data = try! repository.getCart(forId: randomId)
        data.currency = Currency.usd
        let _ = try! repository.updateCart(data: data)
        XCTAssertEqual(repository.carts[data.id]!.currency!, .usd)   // repository has been updated
        XCTAssertTrue(store.updateCalled)   // make sure the store is called
    }
}
