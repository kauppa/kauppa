import Foundation
import XCTest

import KauppaCore
import KauppaCartModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService
@testable import KauppaProductsModel
@testable import KauppaShipmentsModel

class TestReturns: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()
    var couponService = TestCouponService()
    var taxService = TestTaxService()

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
        couponService = TestCouponService()
        taxService = TestTaxService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Service can be called for a return - when it schedules the shipments service with
    // the list of items to be picked up. Full return has a list of all fulfilled items.
    func testFullReturn() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData1 = Product(title: "", subtitle: "", description: "")
        productData1.inventory = 5
        productData1.price = Price(3)
        let product1 = try! productsService.createProduct(with: productData1, from: Address())

        var productData2 = Product(title: "", subtitle: "", description: "")
        productData2.inventory = 5
        productData2.price = Price(10)
        let product2 = try! productsService.createProduct(with: productData2, from: Address())

        let account = try! accountsService.createAccount(with: Account())

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id!,
                                  products: [OrderUnit(for: product1.id!, with: 3),
                                             OrderUnit(for: product2.id!, with: 2)])
        var initial = try! ordersService.createOrder(with: orderData)   // create an order
        // Set the data which is usually set by shipping service.
        initial.products[0].status = OrderUnitStatus(for: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(for: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(with: initial)
        let pickupScheduled = expectation(description: "Order items have been scheduled for pickup")

        // Make sure that shipments service is called for pickup
        shippingService.shipment = Shipment()
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
        let updatedOrder = try! ordersService.returnOrder(for: order.id, with: pickupData)
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 3)
        XCTAssertEqual(updatedOrder.products[1].status!.pickupQuantity, 2)
        let id = shippingService.shipment!.id
        XCTAssertEqual(updatedOrder.shipments[id]!, .pickup)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Returns can be partial, i.e., specific items can be scheduled for pickup.
    func testPartialReturns() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData1 = Product(title: "", subtitle: "", description: "")
        productData1.inventory = 5
        productData1.price = Price(3.0)
        let product1 = try! productsService.createProduct(with: productData1, from: Address())

        var productData2 = Product(title: "", subtitle: "", description: "")
        productData2.inventory = 5
        productData2.price = Price(10.0)
        let product2 = try! productsService.createProduct(with: productData2, from: Address())

        var productData3 = Product(title: "", subtitle: "", description: "")
        productData3.inventory = 5
        productData3.price = Price(5.0)
        let product3 = try! productsService.createProduct(with: productData3, from: Address())

        let account = try! accountsService.createAccount(with: Account())

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id!,
                                  products: [OrderUnit(for: product1.id!, with: 3),
                                             OrderUnit(for: product2.id!, with: 2),
                                             OrderUnit(for: product3.id!, with: 1)])
        var initial = try! ordersService.createOrder(with: orderData)
        // Set the data which is usually set by shipping service.
        initial.products[0].status = OrderUnitStatus(for: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(for: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        initial.products[2].status = OrderUnitStatus(for: 1)
        initial.products[2].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(with: initial)
        let pickup1Scheduled = expectation(description: "pickup scheduled for first partial return")

        // reset shipping data
        shippingService.shipment = Shipment()
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
        pickupData.units = [CartUnit(for: product1.id!, with: 1),
                            CartUnit(for: product3.id!, with: 1)]
        var updatedOrder = try! ordersService.returnOrder(for: order.id, with: pickupData)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfilledQuantity, 3)
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 1)
        // pickup quantity has been updated
        XCTAssertEqual(updatedOrder.products[2].status!.fulfilledQuantity, 1)
        XCTAssertEqual(updatedOrder.products[2].status!.pickupQuantity, 1)

        do {
            // Try returning the same item. This will fail because `product3` only
            // has one item fulfilled, and it's been scheduled for pickup. It can't be
            // picked up again (obviously).
            let _ = try ordersService.returnOrder(for: order.id, with: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .invalidReturnQuantity)
        }

        let pickup2Scheduled = expectation(description: "pickup scheduled for second partial return")
        shippingService.shipment = Shipment()
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

        pickupData.units = [CartUnit(for: product1.id!, with: 2),
                            CartUnit(for: product2.id!, with: 1)]
        updatedOrder = try! ordersService.returnOrder(for: order.id, with: pickupData)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfilledQuantity, 3)
        XCTAssertEqual(updatedOrder.products[1].status!.fulfilledQuantity, 2)
        // pickup quantities have been updated
        XCTAssertEqual(updatedOrder.products[0].status!.pickupQuantity, 3)
        XCTAssertEqual(updatedOrder.products[1].status!.pickupQuantity, 1)
        XCTAssertEqual(updatedOrder.shipments.count, 2)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Cancelled order cannot be returned.
    func testCancelledOrder() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 5
        let product = try! productsService.createProduct(with: productData, from: Address())

        let account = try! accountsService.createAccount(with: Account())

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id!,
                                  products: [OrderUnit(for: product.id!, with: 3)])
        let order = try! ordersService.createOrder(with: orderData)
        let _ = try! ordersService.cancelOrder(for: order.id)
        let pickupData = PickupData()
        do {
            let _ = try ordersService.returnOrder(for: order.id, with: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .cancelledOrder)
        }
    }

    // Possible cases for invalid returns - unfulfilled items, mismatching quantity values, etc.
    func testInvalidReturns() {
        let store = TestStore()
        let repository = OrdersRepository(with: store)
        var productData1 = Product(title: "", subtitle: "", description: "")
        productData1.inventory = 5
        productData1.price = Price(3.0)
        let product1 = try! productsService.createProduct(with: productData1, from: Address())

        var productData2 = Product(title: "", subtitle: "", description: "")
        productData2.inventory = 5
        productData2.price = Price(10.0)
        let product2 = try! productsService.createProduct(with: productData2, from: Address())

        let account = try! accountsService.createAccount(with: Account())

        let ordersService = OrdersService(with: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id!,
                                  products: [OrderUnit(for: product1.id!, with: 3),
                                             OrderUnit(for: product2.id!, with: 2)])
        var initial = try! ordersService.createOrder(with: orderData)
        // Set the data which is usually set by shipping service.
        initial.products[0].status = OrderUnitStatus(for: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(with: initial)

        var pickupData = PickupData()
        pickupData.units = [CartUnit(for: UUID(), with: 2)]
        do {    // Test invalid product
            let _ = try ordersService.returnOrder(for: order.id, with: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .invalidItemId)
        }

        pickupData.units = [CartUnit(for: product2.id!, with: 2)]
        do {    // Test unfulfilled item
            let _ = try ordersService.returnOrder(for: order.id, with: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .unfulfilledItem)
        }

        pickupData.units = [CartUnit(for: product1.id!, with: 5)]
        do {    // Test invalid quantity for fulfilled item
            let _ = try ordersService.returnOrder(for: order.id, with: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .invalidReturnQuantity)
        }

        pickupData.units = []
        do {    // Test no items
            let _ = try ordersService.returnOrder(for: order.id, with: pickupData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .noItemsToProcess)
        }
    }
}
