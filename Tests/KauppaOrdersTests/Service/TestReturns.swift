import Foundation
import XCTest

import KauppaCore
import KauppaProductsModel
import KauppaShipmentsModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestReturns: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()

    static var allTests: [(String, (TestReturns) -> () throws -> Void)] {
        return [
            ("Test full return", testFullReturn),
            ("Test partial returns", testPartialReturns),
            ("Test cancelled order", testCancelledOrder),
            ("Test invalid return data", testInvalidReturns),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        shippingService = TestShipmentsService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFullReturn() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(data: productData)
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2)])
        var initial = try! ordersService.createOrder(data: orderData)   // create an order
        // Set the data which is usually set by shipping service.
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(quantity: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)
        let pickupScheduled = expectation(description: "Order items have been scheduled for pickup")

        // Make sure that shipments service is called for pickup
        shippingService.shipment = Shipment(id: UUID(), createdOn: Date(), updatedAt: Date(),
                                            orderId: UUID(), address: Address())
        shippingService.shipment!.status = .pickup
        shippingService.callback = { any in
            let (id, data) = any as! (UUID, PickupItems)
            XCTAssertEqual(id, order.id)
            XCTAssertEqual(data.items.count, 2)
            XCTAssertEqual(data.items[0].product, product1.id)
            XCTAssertEqual(data.items[0].quantity, 3)
            XCTAssertEqual(data.items[1].product, product2.id)
            XCTAssertEqual(data.items[1].quantity, 2)
            pickupScheduled.fulfill()
        }

        var pickupData = PickupData()
        pickupData.pickupAll = true
        let updatedOrder = try! ordersService.returnOrder(id: order.id, data: pickupData)
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 3)
        XCTAssertEqual(updatedOrder.products[1].status!.pickupQuantity, 2)
        let id = shippingService.shipment!.id
        XCTAssertEqual(updatedOrder.shipments[id]!, .pickup)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testPartialReturns() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(data: productData)
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(data: productData)
        productData.price = UnitMeasurement(value: 5.0, unit: .usd)
        let product3 = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2),
                                             OrderUnit(product: product3.id, quantity: 1)])
        var initial = try! ordersService.createOrder(data: orderData)
        // Set the data which is usually set by shipping service.
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(quantity: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        initial.products[2].status = OrderUnitStatus(quantity: 1)
        initial.products[2].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)
        let pickup1Scheduled = expectation(description: "pickup scheduled for first partial return")

        // reset shipping data
        shippingService.shipment = Shipment(id: UUID(), createdOn: Date(), updatedAt: Date(),
                                            orderId: UUID(), address: Address())
        shippingService.callback = { any in
            let (id, data) = any as! (UUID, PickupItems)
            XCTAssertEqual(id, order.id)
            XCTAssertEqual(data.items.count, 2)
            XCTAssertEqual(data.items[0].product, product1.id)
            XCTAssertEqual(data.items[0].quantity, 1)
            XCTAssertEqual(data.items[1].product, product3.id)
            XCTAssertEqual(data.items[1].quantity, 1)
            pickup1Scheduled.fulfill()
        }

        var pickupData = PickupData()   // first partial return
        pickupData.units = [OrderUnit(product: product1.id, quantity: 1),
                            OrderUnit(product: product3.id, quantity: 1)]
        var updatedOrder = try! ordersService.returnOrder(id: order.id, data: pickupData)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfilledQuantity, 3)
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 1)
        // pickup quantity has been updated
        XCTAssertEqual(updatedOrder.products[2].status!.fulfilledQuantity, 1)
        XCTAssertEqual(updatedOrder.products[2].status!.pickupQuantity, 1)

        do {
            // Try returning the same item. This will fail because `product3` only
            // has one item fulfilled, and it's been scheduled for pickup. It can't be
            // picked up again (obviously).
            let _ = try ordersService.returnOrder(id: order.id, data: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderQuantity(product3.id, 0, false))
        }

        let pickup2Scheduled = expectation(description: "pickup scheduled for second partial return")
        shippingService.shipment = Shipment(id: UUID(), createdOn: Date(), updatedAt: Date(),
                                            orderId: UUID(), address: Address())
        shippingService.callback = { any in
            let (id, data) = any as! (UUID, PickupItems)
            XCTAssertEqual(id, order.id)
            XCTAssertEqual(data.items.count, 2)
            XCTAssertEqual(data.items[0].product, product1.id)
            XCTAssertEqual(data.items[0].quantity, 2)
            XCTAssertEqual(data.items[1].product, product2.id)
            XCTAssertEqual(data.items[1].quantity, 1)
            pickup2Scheduled.fulfill()
        }

        pickupData.units = [OrderUnit(product: product1.id, quantity: 2),
                            OrderUnit(product: product2.id, quantity: 1)]
        updatedOrder = try! ordersService.returnOrder(id: order.id, data: pickupData)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfilledQuantity, 3)
        XCTAssertEqual(updatedOrder.products[1].status!.fulfilledQuantity, 2)
        // pickup quantities have been updated
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 3)
        XCTAssertEqual(updatedOrder.products[1].status!.pickupQuantity, 1)
        XCTAssertEqual(updatedOrder.shipments.count, 3)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    func testCancelledOrder() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        let product = try! productsService.createProduct(data: productData)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product.id, quantity: 3)])
        let order = try! ordersService.createOrder(data: orderData)
        let _ = try! ordersService.cancelOrder(id: order.id)
        let pickupData = PickupData()
        do {
            let _ = try ordersService.returnOrder(id: order.id, data: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .cancelledOrder)
        }
    }

    func testInvalidReturns() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(data: productData)
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2)])
        var initial = try! ordersService.createOrder(data: orderData)
        // Set the data which is usually set by shipping service.
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)

        var pickupData = PickupData()
        pickupData.units = [OrderUnit(product: UUID(), quantity: 2)]
        do {    // Test invalid product
            let _ = try ordersService.returnOrder(id: order.id, data: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderItem)
        }

        pickupData.units = [OrderUnit(product: product2.id, quantity: 2)]
        do {    // Test unfulfilled item
            let _ = try ordersService.returnOrder(id: order.id, data: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product2.id))
        }

        pickupData.units = [OrderUnit(product: product1.id, quantity: 5)]
        do {    // Test invalid quantity for fulfilled item
            let _ = try ordersService.returnOrder(id: order.id, data: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderQuantity(product1.id, 3, false))
        }

        pickupData.units = []
        do {    // Test no items
            let _ = try ordersService.returnOrder(id: order.id, data: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .noItemsToProcess)
        }
    }
}