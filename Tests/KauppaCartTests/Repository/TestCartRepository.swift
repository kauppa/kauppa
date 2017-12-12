import Foundation
import XCTest

@testable import KauppaCore
@testable import KauppaCartModel
@testable import KauppaCartRepository

class TestCartRepository: XCTestCase {
    static var allTests: [(String, (TestCartRepository) -> () throws -> Void)] {
        return [
            ("Test getting cart", testCartGet),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

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
}
