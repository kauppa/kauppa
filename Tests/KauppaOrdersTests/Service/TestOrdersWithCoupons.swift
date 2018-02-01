import Foundation
import XCTest

import KauppaAccountsModel
import KauppaProductsModel
import KauppaCouponModel
@testable import KauppaCore
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestOrdersWithCoupons: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()
    var couponService = TestCouponService()
    var taxService = TestTaxService()

    static var allTests: [(String, (TestOrdersWithCoupons) -> () throws -> Void)] {
        return [
            ("Test order creation with coupons", testOrderCreationWithCoupons),
            ("Test order with invalid coupon", testOrderWithInvalidCoupon),
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

    // Create an order with coupons applied. This should make orders service query
    // the coupon service for getting the coupons, apply them on the totalPrice and finally patch
    // the coupons.
    func testOrderCreationWithCoupons() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 5.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData, from: Address())
        var couponData = CouponData()
        couponData.balance.value = 10.0
        let coupon1 = try! couponService.createCoupon(with: couponData)
        couponData.balance.value = 20.0
        let coupon2 = try! couponService.createCoupon(with: couponData)

        couponService.callbacks[coupon1.id] = { patch in
            XCTAssertEqual(patch.balance!.value, 0.0)   // new balance for the first coupon
        }

        couponService.callbacks[coupon2.id] = { patch in
            XCTAssertEqual(patch.balance!.value, 15.0)  // and the second coupon
        }

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let unit = OrderUnit(product: product.id, quantity: 3)
        var orderData = OrderData(shippingAddress: Address(), billingAddress: nil,
                                  placedBy: account.id, products: [unit])

        // Add two coupons to this order.
        orderData.appliedCoupons.inner = [coupon1.id, coupon2.id]

        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertEqual(order.netPrice.value, 15.0)
        XCTAssertEqual(order.grossPrice.value, 0.0)     // final price (after applying coupons)
    }

    // Test that the orders service carries proper validations on the coupon.\
    // Basically, all errors from `CouponData.deductPrice`
    func testOrderWithInvalidCoupon() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 5.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData, from: Address())
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          couponService: couponService,
                                          taxService: taxService)
        let unit = OrderUnit(product: product.id, quantity: 3)
        var orderData = OrderData(shippingAddress: Address(), billingAddress: nil,
                                  placedBy: account.id, products: [unit])

        var cases = [(UUID, CouponError)]()          // random ID
        cases.append((UUID(), .invalidCouponId))

        var couponData = CouponData()       // by default, coupon has no balance
        var coupon = try! couponService.createCoupon(with: couponData)
        cases.append((coupon.id, .noBalance))

        couponData.balance.value = 10.0
        couponData.balance.unit = .euro       // product price is in USD
        coupon = try! couponService.createCoupon(with: couponData)
        cases.append((coupon.id, .mismatchingCurrencies))

        couponData.disabledOn = Date()        // coupon disabled now
        coupon = try! couponService.createCoupon(with: couponData)
        cases.append((coupon.id, .couponDisabled))

        couponData.expiresOn = Date()         // coupon has expired now
        coupon = try! couponService.createCoupon(with: couponData)
        cases.append((coupon.id, .couponExpired))

        for (id, error) in cases {
            do {
                orderData.appliedCoupons.inner = [id]
                let _ = try ordersService.createOrder(data: orderData)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! CouponError, error)
            }
        }
    }
}
