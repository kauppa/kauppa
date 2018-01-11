import Foundation
import XCTest

@testable import KauppaAccountsModel
@testable import KauppaShipmentsModel
@testable import KauppaShipmentsRepository

class TestShipmentsRepository: XCTestCase {
    let address = Address()

    static var allTests: [(String, (TestShipmentsRepository) -> () throws -> Void)] {
        return [
            ("Test shipment creation", testShipmentCreation),
            ("Test shipment update", testShipmentUpdate),
            ("Test store calls", testStoreCalls),
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Test shipment creation through repository. This should cache the data and call the store.
    func testShipmentCreation() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let data = try! repository.createShipment(forOrder: UUID(), address: address, items: [])
        // creation and updated timestamps should be the same during creation
        XCTAssertEqual(data.createdOn, data.updatedAt)
        XCTAssertNotNil(repository.shipments[data.id])  // valid shipment ID
        XCTAssertEqual(data.status, .shipping)
        XCTAssertTrue(store.createCalled)
    }

    // Updating shipment should change the timestamp and call the store.
    func testShipmentUpdate() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        var data = try! repository.createShipment(forOrder: UUID(), address: address, items: [])
        XCTAssertEqual(data.createdOn, data.updatedAt)
        data.status = .pickup
        let updatedData = try! repository.updateShipment(data: data)
        XCTAssertTrue(updatedData.createdOn != updatedData.updatedAt)   // date has been changed
        XCTAssertTrue(store.updateCalled)   // update called on store
    }

    // Test the repository for proper store calls. If the item doesn't exist in the cache, then
    // it should get from the store and cache it. Re-getting the item shouldn't call the store.
    func testStoreCalls() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let data = try! repository.createShipment(forOrder: UUID(), address: address, items: [])
        repository.shipments = [:]      // clear the repository
        let _ = try! repository.getShipment(id: data.id)
        XCTAssertTrue(store.getCalled)  // this should've called the store
        store.getCalled = false         // now, pretend that we never called the store
        let _ = try! repository.getShipment(id: data.id)
        // store shouldn't be called because it was recently fetched by the repository
        XCTAssertFalse(store.getCalled)
    }
}
