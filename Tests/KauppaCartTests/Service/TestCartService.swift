import Foundation
import XCTest

import KauppaOrdersModel
@testable import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaCartModel
@testable import KauppaCouponModel
@testable import KauppaCartRepository
@testable import KauppaCartService
@testable import KauppaProductsModel
@testable import KauppaTaxModel

class TestCartService: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var ordersService = TestOrdersService()
    let couponService = TestCouponService()
    var taxService = TestTaxService()

    static var allTests: [(String, (TestCartService) -> () throws -> Void)] {
        return [
            ("Test empty cart", testEmptyCart),
            ("Test item addition to cart", testCartItemAddition),
            ("Test item removal from cart", testCartItemRemoval),
            ("Test updating cart items", testCartUpdateItems),
            ("Test getting outdated cart", testOutdatedCart),
            ("Test applying coupon", testCouponApply),
            ("Test invalid coupon applies", testInvalidCoupons),
            ("Test invalid product", testInvalidProduct),
            ("Test invalid acccount", testInvalidAccount),
            ("Test unavailable item", testUnavailableItem),
            ("Test currency ambiguity", testCurrency),
            ("Test placing order", testPlacingOrder),
            ("Test orders failure", testOrdersFail),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        couponService.coupons = [:]
        ordersService = TestOrdersService()
        taxService = TestTaxService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Empty cart shouldn't be calculating taxes, and it shouldn't be allowed to place order.
    func testEmptyCart() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)
        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        // Empty cart shouldn't be calculating any taxes.
        let _ = try! service.getCart(for: account.id, from: Address())
        var checkoutData = CheckoutData()
        checkoutData.shippingAddress = Address()

        do {    // empty cart should fail to place orders
            let _ = try service.placeOrder(for: account.id, with: checkoutData)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.noItemsToProcess)
        }
    }

    // Service should support adding new items to a cart. All accounts have carts.
    func testCartItemAddition() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 10
        productData.price.value = 7.0       // default is USD
        productData.taxCategory = "some unknown category"       // tax should default to general
        let product = try! productsService.createProduct(with: productData, from: Address())

        var anotherProductData = Product(title: "", subtitle: "", description: "")
        anotherProductData.inventory = 10
        anotherProductData.price.value = 13.0
        anotherProductData.taxCategory = "food"
        let anotherProduct = try! productsService.createProduct(with: anotherProductData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        var rate = TaxRate()
        rate.general = 14.0
        rate.categories["food"] = 10.0
        taxService.rate = rate

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        var cartUnit = CartUnit(for: product.id!, with: 4)
        let cart = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())
        XCTAssertEqual(cart.items[0].product, product.id)       // item exists in cart
        XCTAssertEqual(cart.items[0].quantity, 4)
        XCTAssertEqual(cart.items[0].netPrice!.value, 28.0)
        XCTAssertEqual(cart.items[0].tax!.category!, "some unknown category")
        XCTAssertEqual(cart.items[0].tax!.rate, 14.0)
        let taxValue = cart.items[0].tax!.total.value
        XCTAssert(taxValue > 3.919999999999 && taxValue < 3.920000000001)   // FIXME: Floating point mystery
        XCTAssertEqual(cart.items[0].grossPrice!.value, 31.92)
        XCTAssertEqual(cart.netPrice!.value, 28.0)
        XCTAssertEqual(cart.grossPrice!.value, 31.92)

        // 3 more items of the same product (should be merged with the existing item).
        cartUnit = CartUnit(for: product.id!, with: 3)
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())

        cartUnit = CartUnit(for: anotherProduct.id!, with: 5)
        let updatedCart = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())
        XCTAssertEqual(updatedCart.items.count, 2)
        XCTAssertEqual(updatedCart.items[0].quantity, 7)    // quantity has been increased
        XCTAssertEqual(updatedCart.items[0].netPrice!.value, 49.0)
        XCTAssertEqual(updatedCart.items[0].tax!.category!, "some unknown category")
        XCTAssertEqual(updatedCart.items[0].tax!.rate, 14.0)
        XCTAssertEqual(updatedCart.items[0].tax!.total.value, 6.86)
        XCTAssertEqual(updatedCart.items[0].grossPrice!.value, 55.86)
        XCTAssertEqual(updatedCart.items[1].quantity, 5)
        XCTAssertEqual(updatedCart.items[1].netPrice!.value, 65.0)
        XCTAssertEqual(updatedCart.items[1].tax!.category!, "food")
        XCTAssertEqual(updatedCart.items[1].tax!.rate, 10.0)
        XCTAssertEqual(updatedCart.items[1].tax!.total.value, 6.5)
        XCTAssertEqual(updatedCart.items[1].grossPrice!.value, 71.5)
        XCTAssertEqual(updatedCart.netPrice!.value, 114.0)
        XCTAssertEqual(updatedCart.grossPrice!.value, 127.36)
    }

    // Test that removing item from the cart appropriately removes it and changes prices.
    func testCartItemRemoval() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 10
        productData.price.value = 7.0
        productData.taxCategory = "unknown category"    // defaults to general
        let product = try! productsService.createProduct(with: productData, from: Address())
        var anotherProductData = Product(title: "", subtitle: "", description: "")
        anotherProductData.inventory = 10
        anotherProductData.price.value = 13.0
        anotherProductData.taxCategory = "food"
        let anotherProduct = try! productsService.createProduct(with: anotherProductData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        var rate = TaxRate()
        rate.general = 14.0
        rate.categories["food"] = 10.0
        taxService.rate = rate

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)

        var cartUnit = CartUnit(for: product.id!, with: 7)
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())
        cartUnit = CartUnit(for: anotherProduct.id!, with: 5)
        let cart = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())

        XCTAssertEqual(cart.items.count, 2)
        XCTAssertEqual(cart.netPrice!.value, 114.0)
        XCTAssertEqual(cart.grossPrice!.value, 127.36)

        let updatedCart = try! service.removeCartItem(for: account.id, with: product.id!, from: Address())
        XCTAssertEqual(updatedCart.items.count, 1)
        XCTAssertEqual(updatedCart.netPrice!.value, 65.0)
        XCTAssertEqual(updatedCart.grossPrice!.value, 71.5)

        do {    // Try removing random item
            let _ = try service.removeCartItem(for: account.id, with: UUID(), from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidItemId)
        }

        let emptyCart = try! service.removeCartItem(for: account.id, with: anotherProduct.id!, from: Address())
        XCTAssertEqual(emptyCart.items.count, 0)
        XCTAssertNil(emptyCart.netPrice)
        XCTAssertNil(emptyCart.grossPrice)
    }

    // Service should support replacing all cart items in one go.
    func testCartUpdateItems() {
        let store = TestStore()
        let repository = CartRepository(with: store)

        var productData1 = Product(title: "", subtitle: "", description: "")
        productData1.inventory = 10
        productData1.price.value = 5.0
        productData1.taxCategory = "unknown category"       // defaults to general
        let product1 = try! productsService.createProduct(with: productData1, from: Address())

        var productData2 = Product(title: "", subtitle: "", description: "")
        productData2.inventory = 10
        productData2.price.value = 2.5
        productData2.taxCategory = "drink"
        let product2 = try! productsService.createProduct(with: productData2, from: Address())

        var productData3 = Product(title: "", subtitle: "", description: "")
        productData3.inventory = 10
        productData3.price.value = 2
        productData3.taxCategory = "drink"
        let product3 = try! productsService.createProduct(with: productData3, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        var rate = TaxRate()
        rate.general = 10.0
        rate.categories["drink"] = 5.0
        taxService.rate = rate

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)

        var newCart = Cart(with: account.id)
        newCart.items = [CartUnit(for: product1.id!, with: 2), CartUnit(for: product2.id!, with: 4)]
        let cart = try! service.updateCart(for: account.id, with: newCart, from: Address())
        XCTAssertEqual(cart.items.count, 2)
        XCTAssertEqual(cart.netPrice!.value, 20.0)
        XCTAssertEqual(cart.grossPrice!.value, 21.5)

        newCart.items = [CartUnit(for: product1.id!, with: 1), CartUnit(for: product2.id!, with: 2), CartUnit(for: product3.id!, with: 5)]
        let updatedCart = try! service.updateCart(for: account.id, with: newCart, from: Address())
        XCTAssertEqual(updatedCart.items.count, 3)
        XCTAssertEqual(updatedCart.netPrice!.value, 20)
        XCTAssertEqual(updatedCart.grossPrice!.value, 21.25)
    }

    // Service should update the cart when the corresponding products are unavailable.
    func testOutdatedCart() {
        let store = TestStore()
        let repository = CartRepository(with: store)

        var productData1 = Product(title: "", subtitle: "", description: "")
        productData1.inventory = 10
        productData1.price.value = 5.0
        let product1 = try! productsService.createProduct(with: productData1, from: Address())

        var productData2 = Product(title: "", subtitle: "", description: "")
        productData2.inventory = 10
        productData2.price.value = 2.5
        let product2 = try! productsService.createProduct(with: productData2, from: Address())

        var productData3 = Product(title: "", subtitle: "", description: "")
        productData3.inventory = 10
        productData3.price.value = 2
        let product3 = try! productsService.createProduct(with: productData3, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)

        var newCart = Cart(with: account.id)
        newCart.items = [CartUnit(for: product1.id!, with: 1), CartUnit(for: product2.id!, with: 2), CartUnit(for: product3.id!, with: 5)]
        let cart = try! service.updateCart(for: account.id, with: newCart, from: Address())
        XCTAssertEqual(cart.items.count, 3)
        XCTAssertEqual(cart.items[2].quantity, 5)

        // Remove first product from service.
        productsService.products.removeValue(forKey: product1.id!)
        // Set next product's inventory to zero.
        productsService.products[product2.id!]!.inventory = 0
        // Reduce inventory of last product.
        productsService.products[product3.id!]!.inventory = 1

        let updatedCart = try! service.getCart(for: account.id, from: Address())
        XCTAssertEqual(updatedCart.items.count, 1)
        XCTAssertEqual(updatedCart.items[0].quantity, 1)

        do {    // Try increasing the quantity of the last product
            let _ = try service.addCartItem(for: account.id, with: updatedCart.items[0], from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .productUnavailable)
        }
    }

    // Service should support adding coupons only if the cart is non-empty.
    func testCouponApply() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(with: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        do {    // cart is empty
            let _ = try service.applyCoupon(for: account.id, using: CartCoupon(code: ""), from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .noItemsInCart)
        }

        var couponData = CouponData()       // create coupon
        couponData.balance.value = 10.0
        try! couponData.validate()
        let coupon = try! couponService.createCoupon(with: couponData)

        let cartUnit = CartUnit(for: product.id!, with: 4)
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())
        let updatedCart = try! service.applyCoupon(for: account.id,
                                                   using: CartCoupon(code: coupon.data.code!),
                                                   from: Address())
        // apply another time (to ensure we properly ignore duplicated coupons)
        let _ = try! service.applyCoupon(for: account.id,
                                         using: CartCoupon(code: coupon.data.code!),
                                         from: Address())
        XCTAssertEqual(updatedCart.coupons!.inner, [coupon.id])
    }

    // Validation for coupons should also happen in the service.
    func testInvalidCoupons() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(with: productData, from: Address())

        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)

        var couponData = CouponData()       // create coupon
        try! couponData.validate()
        let coupon = try! couponService.createCoupon(with: couponData)

        let cartUnit = CartUnit(for: product.id!, with: 4)    // add sample unit
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())

        // Test cases that should fail a coupon - This ensures that validation
        // happens every time a coupon is applied to a cart.
        let tests: [((inout Coupon) -> (), ServiceError)] = [
            ({ coupon in
                //
            }, .noBalance),
            ({ coupon in
                coupon.data.balance.value = 10.0
                coupon.data.balance.unit = .euro
            }, .ambiguousCurrencies),
            ({ coupon in
                coupon.data.disabledOn = Date()
            }, .couponDisabled),
            ({ coupon in
                coupon.data.expiresOn = Date()
            }, .couponExpired),
        ]

        for (modifyCoupon, error) in tests {
            do {
                var oldCoupon = couponService.coupons[coupon.id]!
                modifyCoupon(&oldCoupon)
                couponService.coupons[coupon.id] = oldCoupon
                let _ = try service.applyCoupon(for: account.id,
                                                using: CartCoupon(code: coupon.data.code!),
                                                from: Address())
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    // If the account does not exist, then adding item and getting cart shouldn't work.
    func testInvalidAccount() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        let cartUnit = CartUnit(for: UUID(), with: 4)
        do {    // random UUID - cannot add item - account doesn't exist
            let _ = try service.addCartItem(for: UUID(), with: cartUnit, from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidAccountId)
        }

        do {    // random UUID - cannot get cart - account doesn't exist
            let _ = try service.getCart(for: UUID(), from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidAccountId)
        }
    }

    // Cart service should add items only if they exist (i.e., when the products service says so).
    func testInvalidProduct() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        let cartUnit = CartUnit(for: UUID(), with: 4)
        do {    // random UUID - product doesn't exist
            let _ = try service.addCartItem(for: account.id, with: cartUnit, from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidProductId)
        }
    }

    // Cart service should check the inventory for required quantity when adding items.
    func testUnavailableItem() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(with: productData, from: Address())
        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        var cartUnit = CartUnit(for: product.id!, with: 15)
        do {
            let _ = try service.addCartItem(for: account.id, with: cartUnit, from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.productUnavailable)
        }

        cartUnit.quantity = 5       // now, we can add it to the cart.
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())
        cartUnit.quantity = 10

        do {    // can't add now, because no more
            let _ = try service.addCartItem(for: account.id, with: cartUnit, from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.productUnavailable)
        }
    }

    // Service should ensure that all product items in the cart use the same currency for price.
    func testCurrency() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productUsdData = Product(title: "", subtitle: "", description: "")
        productUsdData.inventory = 10
        let productUsd = try! productsService.createProduct(with: productUsdData, from: Address())
        var productEuroData = Product(title: "", subtitle: "", description: "")
        productEuroData.inventory = 10
        productEuroData.price.unit = .euro
        let productEuro = try! productsService.createProduct(with: productEuroData, from: Address())
        let accountData = AccountData()
        let account = try! accountsService.createAccount(with: accountData)

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        var cartUnit = CartUnit(for: productUsd.id!, with: 5)
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())
        cartUnit.product = productEuro.id!
        do {    // product with different currency should fail
            let _ = try service.addCartItem(for: account.id, with: cartUnit, from: Address())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.ambiguousCurrencies)
        }
    }

    // Cart service should place the order during a checkout and it should pass the items,
    // applied coupons and the required addresses through order data.
    func testPlacingOrder() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(with: productData, from: Address())
        var anotherProductData = Product(title: "", subtitle: "", description: "")
        anotherProductData.inventory = 10
        let anotherProduct = try! productsService.createProduct(with: anotherProductData, from: Address())

        var accountData = AccountData()
        let address = Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: nil)
        accountData.address.insert(address)
        let account = try! accountsService.createAccount(with: accountData)

        var couponData = CouponData()       // create coupon
        couponData.balance.value = 10.0
        try! couponData.validate()
        let coupon = try! couponService.createCoupon(with: couponData)

        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        var cartUnit = CartUnit(for: product.id!, with: 5)
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: address)
        cartUnit.product = anotherProduct.id!
        cartUnit.quantity = 2
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: address)
        let _ = try! service.applyCoupon(for: account.id,
                                         using: CartCoupon(code: coupon.data.code!), from: address)

        let orderPlaced = expectation(description: "order has been placed")
        ordersService.callback = { data in  // make sure that orders service gets the right data
            XCTAssertEqual(data.products.count, 2)
            XCTAssertEqual(data.products[0].item.product, product.id)
            XCTAssertEqual(data.products[0].item.quantity, 5)
            XCTAssertEqual(data.products[1].item.product, anotherProduct.id)
            XCTAssertEqual(data.products[1].item.quantity, 2)
            XCTAssertEqual(data.appliedCoupons.count, 1)
            XCTAssertEqual(data.appliedCoupons.inner, [coupon.id])
            orderPlaced.fulfill()
        }

        let _ = try! service.placeOrder(for: account.id, with: CheckoutData())
        // Check that items have been flushed. This also ensures that tax isn't calculated
        // because the cart has been reset, and so the prices don't exist.
        let cart = try! service.getCart(for: account.id, from: address)
        XCTAssertTrue(cart.items.isEmpty)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Test for possible errors while placing an order (like shipping address validation,
    // propagating errros from orders service, etc.)
    func testOrdersFail() {
        let store = TestStore()
        let repository = CartRepository(with: store)
        var productData = Product(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(with: productData, from: Address())

        ordersService.error = ServiceError.productUnavailable

        var accountData = AccountData()
        let address = Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: nil)
        accountData.address.insert(address)
        var account = try! accountsService.createAccount(with: accountData)
        let service = CartService(with: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  couponService: couponService,
                                  ordersService: ordersService,
                                  taxService: taxService)
        let cartUnit = CartUnit(for: product.id!, with: 5)
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())

        do {    // errors from orders service should be propagated
            let _ = try service.placeOrder(for: account.id, with: CheckoutData())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.productUnavailable)
        }

        let cart = try! service.getCart(for: account.id, from: Address())
        XCTAssertFalse(cart.items.isEmpty)      // cart items should stay in case of failure

        ordersService.error = nil
        accountData = AccountData()
        account = try! accountsService.createAccount(with: accountData)
        let _ = try! service.addCartItem(for: account.id, with: cartUnit, from: Address())

        do {    // checking out requires a valid shipping address (user doesn't have any)
            let _ = try service.placeOrder(for: account.id, with: CheckoutData())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, ServiceError.invalidAddress)
        }
    }
}
