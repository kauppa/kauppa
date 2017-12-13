import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel
@testable import KauppaCartModel
@testable import KauppaCartRepository
@testable import KauppaCartService

class TestCartService: XCTestCase {
    let productsService = TestProductsService()
    let accountsService = TestAccountsService()
    let ordersService = TestOrdersService()

    static var allTests: [(String, (TestCartService) -> () throws -> Void)] {
        return [
            ("Test item addition to cart", testCartItemAddition),
            ("Test invalid product", testInvalidProduct),
            ("Test invalid acccount", testInvalidAccount),
            ("Test unavailable item", testUnavailableItem),
            ("Test currency ambiguity", testCurrency),
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
                                  ordersService: ordersService)
        let cartUnit = CartUnit(id: product.id, quantity: 4)
        let cart = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        XCTAssertEqual(cart.items[0].productId, product.id)     // item exists in cart
    }

    func testInvalidAccount() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
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

    func testInvalidProduct() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService,
                                  ordersService: ordersService)
        let cartUnit = CartUnit(id: UUID(), quantity: 4)
        do {    // random UUID - product doesn't exist
            let _ = try service.addCartItem(forAccount: account.id, withUnit: cartUnit)
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ProductsError, ProductsError.invalidProduct)
        }
    }

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
}
