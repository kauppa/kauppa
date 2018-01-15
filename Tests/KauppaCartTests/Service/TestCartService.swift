import Foundation
import XCTest

import KauppaGiftsModel
import KauppaOrdersModel
import KauppaProductsModel
@testable import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaCartModel
@testable import KauppaCartRepository
@testable import KauppaCartService

class TestCartService: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var ordersService = TestOrdersService()
    let giftsService = TestGiftsService()

    static var allTests: [(String, (TestCartService) -> () throws -> Void)] {
        return [
            ("Test item addition to cart", testCartItemAddition),
            ("Test applying gift card", testCardApply),
            ("Test invalid gift card applies", testInvalidCards),
            ("Test invalid product", testInvalidProduct),
            ("Test invalid acccount", testInvalidAccount),
            ("Test unavailable item", testUnavailableItem),
            ("Test currency ambiguity", testCurrency),
            ("Test placing order", testPlacingOrder),
            ("Test empty cart", testEmptyCart),
            ("Test orders failure", testOrdersFail),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        giftsService.cards = [:]
        ordersService = TestOrdersService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Service should support adding new items to a cart. All accounts have carts.
    func testCartItemAddition() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        var cartUnit = CartUnit(id: product.id, quantity: 4)
        let cart = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        XCTAssertEqual(cart.items[0].productId, product.id)     // item exists in cart
        XCTAssertEqual(cart.items[0].quantity, 4)
        cartUnit.quantity = 3
        let updatedCart = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        XCTAssertEqual(updatedCart.items.count, 1)          // second item has been merged (same product)
        XCTAssertEqual(updatedCart.items[0].quantity, 7)    // quantity has been increased
    }

    // Service should support adding gift cards only if the cart is non-empty.
    func testCardApply() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        do {    // cart is empty
            let _ = try service.applyGiftCard(forAccount: account.id, code: "")
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CartError, .noItemsInCart)
        }

        var cardData = GiftCardData()       // create gift card
        cardData.balance.value = 10.0
        try! cardData.validate()
        let card = try! giftsService.createCard(withData: cardData)

        let cartUnit = CartUnit(id: product.id, quantity: 4)
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        let updatedCart = try! service.applyGiftCard(forAccount: account.id, code: card.data.code!)
        // apply another time (to ensure we properly ignore duplicated cards)
        let _ = try! service.applyGiftCard(forAccount: account.id, code: card.data.code!)
        XCTAssertEqual(updatedCart.giftCards.inner, [card.id])
    }

    // Validation for gift cards should also happen in the service.
    func testInvalidCards() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)

        var cardData = GiftCardData()       // create gift card
        try! cardData.validate()
        let card = try! giftsService.createCard(withData: cardData)

        let cartUnit = CartUnit(id: product.id, quantity: 4)    // add sample unit
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)

        // Test cases that should fail a gift card - This ensures that validation
        // happens every time a card is applied to a cart.
        let tests: [((inout GiftCard) -> (), GiftsError)] = [
            ({ card in
                //
            }, .noBalance),
            ({ card in
                card.data.balance.value = 10.0
                card.data.balance.unit = .euro
            }, .mismatchingCurrencies),
            ({ card in
                card.data.disabledOn = Date()
            }, .cardDisabled),
            ({ card in
                card.data.expiresOn = Date()
            }, .cardExpired),
        ]

        for (modifyCard, error) in tests {
            do {
                var oldCard = giftsService.cards[card.id]!
                modifyCard(&oldCard)
                giftsService.cards[card.id] = oldCard
                let _ = try service.applyGiftCard(forAccount: account.id, code: card.data.code!)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! GiftsError, error)
            }
        }
    }

    // If the account does not exist, then adding item and getting cart shouldn't work.
    func testInvalidAccount() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        let cartUnit = CartUnit(id: UUID(), quantity: 4)
        do {    // random UUID - cannot add item - account doesn't exist
            let _ = try service.addCartItem(forAccount: UUID(), withUnit: cartUnit)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, AccountsError.invalidAccount)
        }

        do {    // random UUID - cannot get cart - account doesn't exist
            let _ = try service.getCart(forAccount: UUID())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! AccountsError, AccountsError.invalidAccount)
        }
    }

    // Cart service should add items only if they exist (i.e., when the products service says so).
    func testInvalidProduct() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        let cartUnit = CartUnit(id: UUID(), quantity: 4)
        do {    // random UUID - product doesn't exist
            let _ = try service.addCartItem(forAccount: account.id, withUnit: cartUnit)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ProductsError, ProductsError.invalidProduct)
        }
    }

    // Cart service should check the inventory for required quantity when adding items.
    func testUnavailableItem() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(data: productData)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        var cartUnit = CartUnit(id: product.id, quantity: 15)
        do {
            let _ = try service.addCartItem(forAccount: account.id, withUnit: cartUnit)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CartError, CartError.productUnavailable)
        }

        cartUnit.quantity = 5       // now, we can add it to the cart.
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        cartUnit.quantity = 10

        do {    // can't add now, because no more
            let _ = try service.addCartItem(forAccount: account.id, withUnit: cartUnit)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CartError, CartError.productUnavailable)
        }
    }

    // Service should ensure that all product items in the cart use the same currency for price.
    func testCurrency() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let productUsd = try! productsService.createProduct(data: productData)
        productData.price.unit = .euro
        let productEuro = try! productsService.createProduct(data: productData)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        var cartUnit = CartUnit(id: productUsd.id, quantity: 5)
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        cartUnit.productId = productEuro.id
        do {    // product with different currency should fail
            let _ = try service.addCartItem(forAccount: account.id, withUnit: cartUnit)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CartError, CartError.ambiguousCurrencies)
        }
    }

    // Cart service should place the order during a checkout and it should pass the items,
    // applied gift cards and the required addresses through order data.
    func testPlacingOrder() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(data: productData)
        let anotherProduct = try! productsService.createProduct(data: productData)

        var accountData = AccountData()
        let address = Address(name: "foobar", line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: nil)
        accountData.address.insert(address)
        let account = try! accountsService.createAccount(withData: accountData)

        var cardData = GiftCardData()       // create gift card
        cardData.balance.value = 10.0
        try! cardData.validate()
        let card = try! giftsService.createCard(withData: cardData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        var cartUnit = CartUnit(id: product.id, quantity: 5)
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        cartUnit.productId = anotherProduct.id
        cartUnit.quantity = 2
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        let _ = try! service.applyGiftCard(forAccount: account.id, code: card.data.code!)

        let orderPlaced = expectation(description: "order has been placed")
        ordersService.callback = { data in  // make sure that orders service gets the right data
            XCTAssertEqual(data.products.count, 2)
            XCTAssertEqual(data.products[0].product, product.id)
            XCTAssertEqual(data.products[0].quantity, 5)
            XCTAssertEqual(data.products[1].product, anotherProduct.id)
            XCTAssertEqual(data.products[1].quantity, 2)
            XCTAssertEqual(data.appliedGiftCards.count, 1)
            XCTAssertEqual(data.appliedGiftCards.inner, [card.id])
            orderPlaced.fulfill()
        }

        let _ = try! service.placeOrder(forAccount: account.id, data: CheckoutData())
        let cart = try! service.getCart(forAccount: account.id)
        XCTAssertTrue(cart.items.isEmpty)   // check that items have been flushed

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
        }
    }

    // Empty cart shouldn't be allowed to place order.
    func testEmptyCart() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)
        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        do {    // empty cart should fail
            let _ = try service.placeOrder(forAccount: account.id, data: CheckoutData())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CartError, CartError.noItemsToProcess)
        }
    }

    // Test for possible errors while placing an order (like shipping address validation,
    // propagating errros from orders service, etc.)
    func testOrdersFail() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 10
        let product = try! productsService.createProduct(data: productData)

        ordersService.error = OrdersError.productUnavailable

        var accountData = AccountData()
        let address = Address(name: "foobar", line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: nil)
        accountData.address.insert(address)
        var account = try! accountsService.createAccount(withData: accountData)
        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  giftsService: giftsService,
                                  ordersService: ordersService)
        let cartUnit = CartUnit(id: product.id, quantity: 5)
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)

        do {    // errors from orders service should be propagated
            let _ = try service.placeOrder(forAccount: account.id, data: CheckoutData())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! OrdersError, OrdersError.productUnavailable)
        }

        let cart = try! service.getCart(forAccount: account.id)
        XCTAssertFalse(cart.items.isEmpty)      // cart items should stay in case of failure

        ordersService.error = nil
        accountData = AccountData()
        account = try! accountsService.createAccount(withData: accountData)
        let _ = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)

        do {    // checking out requires a valid shipping address (user doesn't have any)
            let _ = try service.placeOrder(forAccount: account.id, data: CheckoutData())
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! CartError, CartError.invalidAddress)
        }
    }
}
