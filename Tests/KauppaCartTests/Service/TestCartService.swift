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
            ("Test cart creation", testCartCreation),
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

    func testCartCreation() {
        let store = TestStore()
        let repository = CartRepository(withStore: store)
        let productData = ProductData(title: "", subtitle: "", description: "")
        let product = try! productsService.createProduct(data: productData)

        let accountData = AccountData()
        let account = try! accountsService.createAccount(withData: accountData)

        let service = CartService(withRepository: repository,
                                  productsService: productsService,
                                  accountsService: accountsService)
        var cartData = CartData()
        let data = try! service.createCart(withData: cartData)
        XCTAssertEqual(data.createdOn, data.updatedAt)
    }
}
