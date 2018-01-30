import Foundation
import XCTest

import KauppaCore
import KauppaProductsModel
import KauppaCartModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestRefunds: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()
    var couponService = TestCouponService()
    var taxService = TestTaxService()

    static var allTests: [(String, (TestRefunds) -> () throws -> Void)] {
        return [
            ("Test full refund", testFullRefund),
            ("Test partial refunds", testPartialRefunds),
            ("Test cancelled order", testCancelledOrder),
            ("Test unpaid refund", testUnpaidRefund),
            ("Test invalid refund data", testInvalidRefunds),
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

    // A refund can be issued once items have been taken back (i.e, when there are refundable items)
    // A full refund happens for all refundable items in an order. This will update the corresponding
    // quantity fields and the item status fields.
    func testFullRefund() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(data: productData, from: Address())
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(data: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2)])
        var initial = try! ordersService.createOrder(data: orderData)
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(quantity: 0)
        initial.products[0].status!.refundableQuantity = 3
        initial.products[1].status = OrderUnitStatus(quantity: 0)
        initial.products[1].status!.refundableQuantity = 2
        let order = try! repository.updateOrder(withData: initial)

        var refundData = RefundData(reason: "")
        do {
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidReason)
        }

        refundData = RefundData(reason: "I hate you!")
        refundData.fullRefund = true
        let updatedOrder = try! ordersService.initiateRefund(forId: order.id, data: refundData)
        // Check the order data
        XCTAssertEqual(updatedOrder.paymentStatus, .refunded)
        // We've revoked everything back from the customer, so there's no fulfillment.
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

    // Partial refunds happen when specific items can be refunded to the customer.
    func testPartialRefunds() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(data: productData, from: Address())
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(data: productData, from: Address())
        productData.price = UnitMeasurement(value: 5.0, unit: .usd)
        let product3 = try! productsService.createProduct(data: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2),
                                             OrderUnit(product: product3.id, quantity: 1)])
        var initial = try! ordersService.createOrder(data: orderData)
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(quantity: 0)
        initial.products[0].status!.refundableQuantity = 3
        initial.products[1].status = OrderUnitStatus(quantity: 0)
        initial.products[1].status!.refundableQuantity = 2
        initial.products[2].status = OrderUnitStatus(quantity: 0)
        initial.products[2].status!.refundableQuantity = 1
        let order = try! repository.updateOrder(withData: initial)

        var refundData = RefundData(reason: "Boo!")
        refundData.units = [CartUnit(product: product1.id, quantity: 1),
                            CartUnit(product: product3.id, quantity: 1)]
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
        XCTAssertEqual(updatedOrder.products[0].status!.refundableQuantity, 2)
        XCTAssertEqual(updatedOrder.products[0].status!.fulfillment, .partial)
        // `product3` has been refunded entirely, so it's `nil`
        XCTAssertNil(updatedOrder.products[2].status)

        // Now try and refund the remaining units
        refundData.units = [CartUnit(product: product1.id, quantity: 2),
                            CartUnit(product: product2.id, quantity: 2)]
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

    // Cancelled orders cannot be refunded.
    func testCancelledOrder() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData, from: Address())
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
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

    // If the payment hasn't been received for an order, then it cannot be refunded.
    func testUnpaidRefund() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData, from: Address())
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
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

    // A number of cases when refund can fail - item doesn't exist in order, item hasn't been fulfilled,
    // item hasn't been returned, etc.
    func testInvalidRefunds() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 3.0, unit: .usd)
        let product1 = try! productsService.createProduct(data: productData, from: Address())
        productData.price = UnitMeasurement(value: 10.0, unit: .usd)
        let product2 = try! productsService.createProduct(data: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let orderData = OrderData(shippingAddress: Address(), billingAddress: nil, placedBy: account.id,
                                  products: [OrderUnit(product: product1.id, quantity: 3),
                                             OrderUnit(product: product2.id, quantity: 2)])
        var initial = try! ordersService.createOrder(data: orderData)
        // Set the data which is usually set by payments and shipping services.
        initial.paymentStatus = .paid
        initial.products[0].status = OrderUnitStatus(quantity: 0)
        initial.products[0].status!.refundableQuantity = 3
        let order = try! repository.updateOrder(withData: initial)

        var refundData = RefundData(reason: "Boo!")

        refundData.units = [CartUnit(product: UUID(), quantity: 2)]
        do {    // Test invalid product
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidOrderItem)
        }

        refundData.units = [CartUnit(product: product2.id, quantity: 2)]
        do {    // Test unfulfilled item
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .unfulfilledItem(product2.id))
        }

        refundData.units = [CartUnit(product: product1.id, quantity: 5)]
        do {    // Test invalid quantity for refundable item
            let _ = try ordersService.initiateRefund(forId: order.id, data: refundData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, .invalidRefundQuantity(product1.id, 3))
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
