import Foundation
import XCTest

@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository

class TestOrdersRepository: XCTestCase {
    static var allTests: [(String, (TestOrdersRepository) -> () throws -> Void)] {
        return [
            ("Test order creation", testOrderCreation),
            ("Test order deletion", testOrderDeletion),
            ("Test order update", testOrderUpdate),
            ("Test store calls", testStoreCalls),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test order creation in repository. This just checks for timestamps, caching and store calls.
    func testOrderCreation() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let data = Order(placedBy: UUID())
        try! repository.createOrder(withData: data)
        // creation and updated timestamps should be the same during creation
        XCTAssertEqual(data.createdOn, data.updatedAt)
        XCTAssertNotNil(repository.orders[data.id])
        XCTAssertTrue(store.createCalled)       // store's create method called by repository
    }

    // Test order deletion - should delete from cache and call store.
    func testOrderDeletion() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let data = Order(placedBy: UUID())
        try! repository.createOrder(withData: data)
        let _ = try! repository.deleteOrder(id: data.id)
        XCTAssertTrue(store.deleteCalled)   // store's delete method called by repository
        XCTAssertNil(repository.orders[data.id])    // order has been removed from repository
    }

    // Updating order data in repository should update timestamp, cache and call the store.
    func testOrderUpdate() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let order = Order(placedBy: UUID())
        try! repository.createOrder(withData: order)
        XCTAssertEqual(order.createdOn, order.updatedAt)
        let update1 = try! repository.updateOrder(withData: order, skipDate: true)
        XCTAssertEqual(update1.createdOn, update1.updatedAt)    // date is still the same
        let update2 = try! repository.updateOrder(withData: order)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertTrue(update2.createdOn != update2.updatedAt)
        XCTAssertTrue(store.updateCalled)   // update called on store
    }

    // Test the repository for proper store calls. If the item doesn't exist in the cache, then
    // it should get from the store and cache it. Re-getting the item shouldn't call the store.
    func testStoreCalls() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let data = Order(placedBy: UUID())
        try! repository.createOrder(withData: data)
        repository.orders = [:]     // clear the repository
        let _ = try! repository.getOrder(id: data.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try! repository.getOrder(id: data.id)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
