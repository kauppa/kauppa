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

    static var allTests: [(String, (TestCartService) -> () throws -> Void)] {
        return [
            ("Test item addition to cart", testCartItemAddition),
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
        let productData = ProductData(title: "", subtitle: "", description: "")
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService)
        let cartUnit = CartUnit(id: product.id, quantity: 4)
        let cart = try! service.addCartItem(forAccount: account.id, withUnit: cartUnit)
        XCTAssertEqual(cart.items[0].productId, product.id)     // item exists in cart
    }
}
