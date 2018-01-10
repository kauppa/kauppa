import Foundation
import XCTest

import KauppaCore
import KauppaOrdersModel
@testable import KauppaAccountsModel
@testable import KauppaShipmentsModel
@testable import KauppaShipmentsRepository
@testable import KauppaShipmentsService

class TestShipmentsService: XCTestCase {
    var ordersService = TestOrdersService()

    static var allTests: [(String, (TestShipmentsService) -> () throws -> Void)] {
        return [
            ("Test successful shipment creation", testShipmentCreation),
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

    // Service supports creating shipments - this should check that the order ID is valid.
    func testShipmentCreation() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        let id = UUID()
        ordersService.order.id = id
        ordersService.order.shippingAddress = Address()
        ordersService.order.products = [OrderUnit(product: UUID(), quantity: 10)]
        let data = try! service.createShipment(forOrder: id)
        XCTAssertEqual(data.createdOn, data.updatedAt)      // created and updated timestamps are equal
        XCTAssertEqual(data.orderId, id)    // shipment is bound to this order ID.
        XCTAssertEqual(data.items.count, 1)     // order unit is obtained from orders service.
        XCTAssertEqual(data.items[0].product, ordersService.order.products[0].product)
    }

    // Service supports scheduling pickups.
    func testPickupSchedule() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        let _ = try! service.createShipment(forOrder: ordersService.order.id)
        let data = try! service.schedulePickup(forOrder: ordersService.order.id, data: PickupItems())
        XCTAssertEqual(data.status, .pickup)
    }

    // Once a pickup completes, the service should notify orders about the event.
    func testPickupCompletion() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        ordersService.order.id = UUID()
        ordersService.order.shippingAddress = Address()
        let productId = UUID()
        ordersService.order.products = [OrderUnit(product: productId, quantity: 10)]
        var data = try! service.createShipment(forOrder: ordersService.order.id)
        do {    // cannot complete pickup if it's 'shipping'
            let _ = try service.completePickup(id: data.id)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ShipmentsError, .notScheduledForPickup)
        }

        var pickupData = PickupItems()
        pickupData.items = [OrderUnit(product: productId, quantity: 5)]
        data = try! service.schedulePickup(forOrder: ordersService.order.id, data: pickupData)
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

        let updatedData = try! service.completePickup(id: data.id)
        XCTAssertEqual(updatedData.status, .returned)

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    // Delivery should also be notified to orders.
    func testNotifyDelivery() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        ordersService.order.id = UUID()
        ordersService.order.shippingAddress = Address()
        let productId = UUID()
        ordersService.order.products = [OrderUnit(product: productId, quantity: 5)]
        let data = try! service.createShipment(forOrder: ordersService.order.id)
        do {    // by default, status is "shipping" (it hasn't "shipped", so it cannot be delivered)
            let _ = try service.notifyDelivery(id: data.id)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ShipmentsError, .notBeingShipped)
        }

        let _ = try! service.notifyShipping(id: data.id)
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

        let updatedData = try! service.notifyDelivery(id: data.id)
        XCTAssertEqual(updatedData.status, .delivered)

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }

    // Once a shipment is created, its status will be `shipping`, and when it gets shipped,
    // it should notify orders about it.
    func testNotifyShipping() {
        let store = TestStore()
        let repository = ShipmentsRepository(withStore: store)
        let service = ShipmentsService(withRepository: repository, ordersService: ordersService)
        ordersService.order.id = UUID()
        ordersService.order.shippingAddress = Address()
        let productId = UUID()
        ordersService.order.products = [OrderUnit(product: productId, quantity: 2)]
        var data = try! service.createShipment(forOrder: ordersService.order.id)

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

        data = try! service.notifyShipping(id: data.id)
        XCTAssertEqual(data.status, .shipped)

        do {    // It's been shipped, it cannot be shipped again
            let _ = try service.notifyShipping(id: data.id)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ShipmentsError, .notQueuedForShipping)
        }

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
        }
    }
}
