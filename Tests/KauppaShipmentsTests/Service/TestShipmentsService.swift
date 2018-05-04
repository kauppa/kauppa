import Foundation
import XCTest

import KauppaCore
import KauppaOrdersModel
import KauppaCartModel
@testable import KauppaAccountsModel
@testable import KauppaShipmentsModel
@testable import KauppaShipmentsRepository
@testable import KauppaShipmentsService

class TestShipmentsService: XCTestCase {
    var ordersService = TestOrdersService()

    static var allTests: [(String, (TestShipmentsService) -> () throws -> Void)] {
        return [
            ("Test shipment creation for order", testShipmentCreationOrder),
            ("Test shipment creation for line items", testShipmentCreationItems),
            ("Test pickup schedule", testPickupSchedule),
            ("Test pickup completion", testPickupCompletion),
            ("Test delivery notification", testNotifyDelivery),
            ("Test shipped notification", testNotifyShipping),
        ]
    }

    override func setUp() {
        ordersService = TestOrdersService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Service supports creating shipments for all items in order.
    func testShipmentCreationOrder() {
        let store = TestStore()
        let repository = ShipmentsRepository(with: store)
        let service = ShipmentsService(with: repository, ordersService: ordersService)
        let id = UUID()
        ordersService.order.id = id
        ordersService.order.shippingAddress = Address()
        ordersService.order.products = [OrderUnit(for: UUID(), with: 10)]

        let orderNotified = expectation(description: "orders service notified of shipping")
        ordersService.callback = { any in
            let (_, notifyData) = any as! (UUID, Shipment)
            XCTAssertEqual(notifyData.items.count, 1)
            XCTAssertEqual(notifyData.items[0].product, self.ordersService.order.products[0].item.product)
            orderNotified.fulfill()
        }

        let data = try! service.createShipment(for: id, with: [])
        XCTAssertEqual(data.createdOn, data.updatedAt)      // created and updated timestamps are equal
        XCTAssertEqual(data.orderId, id)    // shipment is bound to this order ID.
        XCTAssertEqual(data.items.count, 1)     // order unit is obtained from orders service.
        XCTAssertEqual(data.items[0].product, ordersService.order.products[0].item.product)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Service supports creating shipments for individual items with quantities from order.
    func testShipmentCreationItems() {
        let store = TestStore()
        let repository = ShipmentsRepository(with: store)
        let service = ShipmentsService(with: repository, ordersService: ordersService)
        let id = UUID()
        ordersService.order.id = id
        ordersService.order.shippingAddress = Address()
        ordersService.order.products = []

        do {
            let _ = try service.createShipment(for: id, with: nil)
            XCTFail()
        } catch let err {   // Order has no products - practical impossibility
            XCTAssertEqual(err as! ServiceError, .noItemsToProcess)
        }

        let product1 = UUID()
        let product2 = UUID()

        ordersService.order.products = [OrderUnit(for: product1, with: 10), OrderUnit(for: product2, with: 3)]
        var items = [CartUnit(for: UUID(), with: 21), CartUnit(for: product2, with: 0)]

        do {
            let _ = try service.createShipment(for: id, with: items)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .invalidItemId)
        }

        items[0].product = product1
        items.append(CartUnit(for: product1, with: 5))      // duplicate

        let shipment = try! service.createShipment(for: id, with: items)
        XCTAssertEqual(shipment.items.count, 1)
        XCTAssertEqual(shipment.items[0].quantity, 10)
    }

    // Service supports scheduling pickups.
    func testPickupSchedule() {
        let store = TestStore()
        let repository = ShipmentsRepository(with: store)
        ordersService.order.products = [OrderUnit(for: UUID(), with: 10)]
        let service = ShipmentsService(with: repository, ordersService: ordersService)
        let _ = try! service.createShipment(for: ordersService.order.id, with: nil)
        let data = try! service.schedulePickup(for: ordersService.order.id, with: PickupItems())
        XCTAssertEqual(data.status, .pickup)
    }

    // Once a pickup completes, the service should notify orders about the event.
    func testPickupCompletion() {
        let store = TestStore()
        let repository = ShipmentsRepository(with: store)
        let service = ShipmentsService(with: repository, ordersService: ordersService)
        ordersService.order.id = UUID()
        ordersService.order.shippingAddress = Address()
        let productId = UUID()
        ordersService.order.products = [OrderUnit(for: productId, with: 10)]
        var data = try! service.createShipment(for: ordersService.order.id, with: nil)
        do {    // cannot complete pickup if it's 'shipping'
            let _ = try service.completePickup(for: data.id)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .notScheduledForPickup)
        }

        var pickupData = PickupItems()
        pickupData.items = [CartUnit(for: productId, with: 5)]
        data = try! service.schedulePickup(for: ordersService.order.id, with: pickupData)
        let orderNotified = expectation(description: "orders service notified of pickup completion")
        ordersService.callback = { any in
            let (id, notifyData) = any as! (UUID, Shipment)
            XCTAssertEqual(id, self.ordersService.order.id)
            XCTAssertEqual(notifyData.status, .returned)
            XCTAssertEqual(notifyData.items.count, 1)
            XCTAssertEqual(notifyData.items[0].product, productId)
            XCTAssertEqual(notifyData.items[0].quantity, 5)     // 5 items have been picked up
            orderNotified.fulfill()
        }

        let updatedData = try! service.completePickup(for: data.id)
        XCTAssertEqual(updatedData.status, .returned)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Delivery should also be notified to orders.
    func testNotifyDelivery() {
        let store = TestStore()
        let repository = ShipmentsRepository(with: store)
        let service = ShipmentsService(with: repository, ordersService: ordersService)
        ordersService.order.id = UUID()
        ordersService.order.shippingAddress = Address()
        let productId = UUID()
        ordersService.order.products = [OrderUnit(for: productId, with: 5)]
        let data = try! service.createShipment(for: ordersService.order.id, with: nil)
        do {    // by default, status is "shipping" (it hasn't "shipped", so it cannot be delivered)
            let _ = try service.notifyDelivery(for: data.id)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .notBeingShipped)
        }

        let _ = try! service.notifyShipping(for: data.id)
        let orderNotified = expectation(description: "orders service notified of delivery")
        ordersService.callback = { any in
            let (id, notifyData) = any as! (UUID, Shipment)
            XCTAssertEqual(id, self.ordersService.order.id)
            XCTAssertEqual(notifyData.status, .delivered)
            XCTAssertEqual(notifyData.items.count, 1)
            XCTAssertEqual(notifyData.items[0].product, productId)
            XCTAssertEqual(notifyData.items[0].quantity, 5)
            orderNotified.fulfill()
        }

        let updatedData = try! service.notifyDelivery(for: data.id)
        XCTAssertEqual(updatedData.status, .delivered)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Once a shipment is created, its status will be `shipping`, and when it gets shipped,
    // it should notify orders about it.
    func testNotifyShipping() {
        let store = TestStore()
        let repository = ShipmentsRepository(with: store)
        let service = ShipmentsService(with: repository, ordersService: ordersService)
        ordersService.order.id = UUID()
        ordersService.order.shippingAddress = Address()
        let productId = UUID()
        ordersService.order.products = [OrderUnit(for: productId, with: 2)]
        var data = try! service.createShipment(for: ordersService.order.id, with: nil)

        let orderNotified = expectation(description: "orders service notified of shipment")
        ordersService.callback = { any in
            let (id, notifyData) = any as! (UUID, Shipment)
            XCTAssertEqual(id, self.ordersService.order.id)
            XCTAssertEqual(notifyData.status, .shipped)
            XCTAssertEqual(notifyData.items.count, 1)
            XCTAssertEqual(notifyData.items[0].product, productId)
            XCTAssertEqual(notifyData.items[0].quantity, 2)
            orderNotified.fulfill()
        }

        data = try! service.notifyShipping(for: data.id)
        XCTAssertEqual(data.status, .shipped)

        do {    // It's been shipped, it cannot be shipped again
            let _ = try service.notifyShipping(for: data.id)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .notQueuedForShipping)
        }

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }
}
