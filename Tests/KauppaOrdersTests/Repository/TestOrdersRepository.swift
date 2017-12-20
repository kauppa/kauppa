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

    func testOrderCreation() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let orderData = Order()
        let data = try? repository.createOrder(withData: orderData)
        XCTAssertNotNil(data)
        // creation and updated timestamps should be the same during creation
        XCTAssertEqual(data!.createdOn, data!.updatedAt)
        XCTAssertNotNil(repository.orders[data!.id!])   // valid order ID
        XCTAssertTrue(store.createCalled)       // store's create method called by repository
    }

    func testOrderDeletion() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let orderData = Order()
        let data = try! repository.createOrder(withData: orderData)
        let _ = try! repository.deleteOrder(id: data.id!)
        XCTAssertTrue(store.deleteCalled)   // store's delete method called by repository
        XCTAssertNil(repository.orders[data.id!])   // order has been removed from repository
    }

    func testOrderUpdate() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let orderData = Order()
        let order = try! repository.createOrder(withData: orderData)
        XCTAssertEqual(order.createdOn!, order.updatedAt!)
        let update1 = try! repository.updateOrder(withData: order, skipDate: true)
        XCTAssertEqual(update1.createdOn!, update1.updatedAt!)  // date is still the same
        let update2 = try! repository.updateOrder(withData: order)
        // We're just testing the function calls (extensive testing is done in service)
        XCTAssertTrue(update2.createdOn! != update2.updatedAt!)
        XCTAssertTrue(store.updateCalled)   // update called on store
    }

    func testStoreCalls() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let orderData = Order()
        let data = try! repository.createOrder(withData: orderData)
        repository.orders = [:]     // clear the repository
        let _ = try! repository.getOrder(id: data.id!)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try! repository.getOrder(id: data.id!)
        // store shouldn't be called, because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
