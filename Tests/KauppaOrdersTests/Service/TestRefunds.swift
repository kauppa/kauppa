import Foundation
import XCTest

import KauppaCore
import KauppaProductsModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestRefunds: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    let shippingService = TestShipmentsService()

    static var allTests: [(String, (TestRefunds) -> () throws -> Void)] {
        return [
            ("Test full refund", testFullRefund),
            ("Test partial refunds", testPartialRefunds),
            ("Test refund with no reason", testRefundNoReason),
            ("Test cancelled order", testCancelledOrder),
            ("Test unpaid refund", testUnpaidRefund),
            ("Test invalid refund data", testInvalidRefunds),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFullRefund() {
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
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(quantity: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)

        var refundData = RefundData(reason: "I hate you!")
        refundData.fullRefund = true
        let updatedOrder = try! ordersService.initiateRefund(forId: order.id, data: refundData)
        // Check the order data
        XCTAssertEqual(updatedOrder.paymentStatus, .refunded)
        // We've revoked everything back from the customer. So, there's
        // no fulfillment.
        XCTAssertNil(updatedOrder.fulfillment)
        XCTAssertNil(updatedOrder.products[0].status)
        XCTAssertNil(updatedOrder.products[1].status)
        // Check the refund data
        let refund = store.refunds[updatedOrder.refunds[0]]!
        XCTAssertEqual(updatedOrder.refunds, [refund.id])   // refund is listed in order
        XCTAssertEqual(refund.amount.value, 29.0)   // total refund amount
        XCTAssertEqual(refund.amount.unit, .usd)
        XCTAssertEqual(refund.items.count, 2)
        XCTAssertEqual(refund.items[0].product, product1.id)
        XCTAssertEqual(refund.items[0].quantity, 3)
        XCTAssertEqual(refund.items[1].product, product2.id)
        XCTAssertEqual(refund.items[1].quantity, 2)
        XCTAssertEqual(refund.orderId, order.id)    // refund has order ID
        XCTAssertEqual(refund.reason, refundData.reason)
    }

    func testPartialRefunds() {
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
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        initial.products[1].status = OrderUnitStatus(quantity: 2)
        initial.products[1].status!.fulfillment = .fulfilled
        initial.products[2].status = OrderUnitStatus(quantity: 1)
        initial.products[2].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)

        var refundData = RefundData(reason: "Boo!")
        refundData.units = [OrderUnit(product: product1.id, quantity: 1),
                            OrderUnit(product: product3.id, quantity: 1)]
        let updatedOrder = try! ordersService.initiateRefund(forId: order.id, data: refundData)
        XCTAssertEqual(updatedOrder.refunds.count, 1)
        let refund1 = store.refunds[updatedOrder.refunds[0]]!
        XCTAssertEqual(refund1.amount.value, 8.0)
        XCTAssertEqual(refund1.items.count, 2)
        XCTAssertEqual(refund1.items[0].product, product1.id)
        XCTAssertEqual(refund1.items[0].quantity, 1)
        XCTAssertEqual(refund1.items[1].product, product3.id)
        XCTAssertEqual(refund1.items[1].quantity, 1)
        // Some of the data will be set to partial fulfillment
        XCTAssertEqual(updatedOrder.paymentStatus, .partialRefund)
        XCTAssertEqual(updatedOrder.fulfillment, .partial)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfilledQuantity, 2)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfillment, .partial)
        // `product3` has been refunded entirely, so it's `nil`
        XCTAssertNil(updatedOrder.products[2].status)

        // Now try and refund the remaining units
        refundData.units = [OrderUnit(product: product1.id, quantity: 2),
                            OrderUnit(product: product2.id, quantity: 2)]
        let finalUpdate = try! ordersService.initiateRefund(forId: order.id, data: refundData)
        XCTAssertEqual(finalUpdate.refunds.count, 2)
        XCTAssertEqual(finalUpdate.paymentStatus, .refunded)
        XCTAssertNil(finalUpdate.fulfillment)
        // Ensure complete refund by now
        let refund2 = store.refunds[finalUpdate.refunds[1]]!
        XCTAssertEqual(refund2.amount.value, 26.0)
        XCTAssertEqual(refund2.items.count, 2)
        XCTAssertEqual(refund2.items[0].product, product1.id)
        XCTAssertEqual(refund2.items[0].quantity, 2)
        XCTAssertEqual(refund2.items[1].product, product2.id)
        XCTAssertEqual(refund2.items[1].quantity, 2)

        do {   // now, try refunding again
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .refundedOrder)
        }
    }

    func testRefundNoReason() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let refundData = RefundData(reason: "")
        do {
            let _ = try ordersService.initiateRefund(forId: UUID(), data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidReason)
        }
    }

    func testCancelledOrder() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
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
        let refundData = RefundData(reason: "Booya!")
        do {
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .cancelledOrder)
        }
    }

    func testUnpaidRefund() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product.id, quantity: 3)])
        var order = try! ordersService.createOrder(data: orderData)
        let refundData = RefundData(reason: "Booya!")
        do {    // by default, the payment status is 'pending'
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .paymentNotReceived)
        }

        order.paymentStatus = .failed   // check for failed payment
        let _ = try! repository.updateOrder(withData: order)
        do {
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .paymentNotReceived)
        }
    }

    func testInvalidRefunds() {
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
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(quantity: 3)
        initial.products[0].status!.fulfillment = .fulfilled
        let order = try! repository.updateOrder(withData: initial)

        var refundData = RefundData(reason: "Boo!")

        refundData.units = [OrderUnit(product: UUID(), quantity: 2)]
        do {    // Test invalid product
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderItem)
        }

        refundData.units = [OrderUnit(product: product2.id, quantity: 2)]
        do {    // Test unfulfilled item
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product2.id))
        }

        refundData.units = [OrderUnit(product: product1.id, quantity: 5)]
        do {    // Test invalid quantity for fulfilled item
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderQuantity(product1.id, 3))
        }

        refundData.units = []
        do {    // Test no items
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .noItemsToProcess)
        }
    }
}
