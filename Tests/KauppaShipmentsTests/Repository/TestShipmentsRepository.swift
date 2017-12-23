import Foundation
import XCTest

@testable import KauppaShipmentsModel
@testable import KauppaShipmentsRepository

class TestShipmentsRepository: XCTestCase {
    static var allTests: [(String, (TestShipmentsRepository) -> () throws -> Void)] {
        return [
            ("Test shipment creation", testShipmentCreation)
        ]
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testShipmentCreation() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let data = try! repository.createShipment(forOrder: UUID(), items: [])
        // creation and updated timestamps should be the same during creation
        XCTAssertEqual(data.createdOn, data.updatedAt)
        XCTAssertNotNil(repository.shipments[data.id])  // valid shipment ID
        XCTAssertTrue(store.createCalled)
    }
}
