import Foundation
import XCTest

import KauppaCore
import KauppaProductsModel
import KauppaGiftsModel
@testable import KauppaAccountsModel
@testable import KauppaOrdersModel
@testable import KauppaOrdersRepository
@testable import KauppaOrdersService

class TestGiftedOrders: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    var shippingService = TestShipmentsService()
    var giftsService = TestGiftsService()

    static var allTests: [(String, (TestGiftedOrders) -> () throws -> Void)] {
        return [
            ("Test order creation with gift cards", testOrderCreationWithGiftCards),
            ("Test order with invalid card", testOrderWithInvalidCard),
        ]
    }

    override func setUp() {
        productsService.products = [:]
        accountsService.accounts = [:]
        shippingService = TestShipmentsService()
        giftsService = TestGiftsService()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testOrderCreationWithGiftCards() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 5.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData)

        var cardData = GiftCardData()
        cardData.balance.value = 10.0
        let card1 = try! giftsService.createCard(withData: cardData)
        cardData.balance.value = 20.0
        let card2 = try! giftsService.createCard(withData: cardData)

        giftsService.callbacks[card1.id] = { patch in
            XCTAssertEqual(patch.balance!.value, 0.0)   // new balance for the first card
        }

        giftsService.callbacks[card2.id] = { patch in
            XCTAssertEqual(patch.balance!.value, 15.0)  // and the second card
        }

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          giftsService: giftsService)
        let unit = OrderUnit(product: product.id, quantity: 3)
        var orderData = OrderData(shippingAddress: Address(), billingAddress: nil,
                                  placedBy: account.id, products: [unit])

        // Add two cards to this order.
        orderData.appliedGiftCards = [card1.id, card2.id]

        let order = try! ordersService.createOrder(data: orderData)
        XCTAssertEqual(order.totalPrice.value, 15.0)
        XCTAssertEqual(order.finalPrice.value, 0.0)     // final price (after applying cards)
    }

    func testOrderWithInvalidCard() {
        let store = TestStore()
        let repository = OrdersRepository(withStore: store)
        var productData = ProductData(title: "", subtitle: "", description: "")
        productData.inventory = 5
        productData.price = UnitMeasurement(value: 5.0, unit: .usd)
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let ordersService = OrdersService(withRepository: repository,
                                          accountsService: accountsService,
                                          productsService: productsService,
                                          shippingService: shippingService,
                                          giftsService: giftsService)
        let unit = OrderUnit(product: product.id, quantity: 3)
        var orderData = OrderData(shippingAddress: Address(), billingAddress: nil,
                                  placedBy: account.id, products: [unit])

        var cases = [(UUID, GiftsError)]()          // random ID
        cases.append((UUID(), .invalidGiftCardId))

        var cardData = GiftCardData()       // by default, card has no balance
        var card = try! giftsService.createCard(withData: cardData)
        cases.append((card.id, .noBalance))

        cardData.balance.value = 10.0
        cardData.balance.unit = .euro       // product price is in USD
        card = try! giftsService.createCard(withData: cardData)
        cases.append((card.id, .mismatchingCurrencies))

        cardData.disabledOn = Date()        // card disabled now
        card = try! giftsService.createCard(withData: cardData)
        cases.append((card.id, .cardDisabled))

        cardData.expiresOn = Date()         // card has expired now
        card = try! giftsService.createCard(withData: cardData)
        cases.append((card.id, .cardExpired))

        for (id, error) in cases {
            do {
                orderData.appliedGiftCards = [id]
                let _ = try ordersService.createOrder(data: orderData)
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! GiftsError, error)
            }
        }
    }
}
