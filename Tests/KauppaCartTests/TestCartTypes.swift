import Foundation
import XCTest

import KauppaCore
import KauppaAccountsModel
@testable import KauppaCartModel
@testable import KauppaTaxModel
@testable import TestTypes

class TestCartTypes: XCTestCase {
    static var allTests: [(String, (TestCartTypes) -> () throws -> Void)] {
        return [
            ("Test cart reset", testCartReset),
            ("Test cart price setting", testCartSetPrices),
            ("Test cart unit reset", testCartUnitReset),
            ("Test cart unit price setting", testCartUnitSetPrices),
            ("Test cart checkout data validation", testCheckoutValidation),
        ]
    }

    /// Check that reseting cart unit properly resets the necessary properties.
    func testCartUnitReset() {
        var unit = CartUnit(for: UUID(), with: 5)
        unit.tax = UnitTax()
        unit.tax!.category = "something"
        unit.tax!.rate = 25.0
        unit.tax!.total = Price(5.0)
        unit.netPrice = Price(5.0)
        unit.grossPrice = Price(6.25)

        unit.resetInternalProperties()
        XCTAssertNil(unit.tax!.category)
        XCTAssertEqual(unit.tax!.rate, 0.0)
        XCTAssertEqual(unit.tax!.total.value, 0.0)
        XCTAssertNil(unit.netPrice)
        XCTAssertNil(unit.grossPrice)
    }

    /// Test setting tax and prices in cart unit.
    func testCartUnitSetPrices() {
        var unit = CartUnit(for: UUID(), with: 5)
        unit.tax = UnitTax()
        unit.tax!.category = "drink"
        unit.netPrice = Price(5.0)
        var rate = TaxRate()
        rate.categories["drink"] = 10.0
        unit.setPrices(using: rate)

        XCTAssertEqual(unit.tax!.category!, "drink")
        TestApproxEqual(unit.tax!.total.value, 0.5)
        XCTAssertEqual(unit.tax!.rate, 10.0)
        XCTAssertEqual(unit.grossPrice!.value, 5.5)
    }

    /// Check that reseting cart properly sets all internal properties to `nil`.
    func testCartReset() {
        var cart = Cart(with: UUID())
        cart.items.append(CartUnit(for: UUID(), with: 5))
        cart.netPrice = Price(5.0)
        cart.grossPrice = Price(5.5)
        cart.coupons = ArraySet([UUID()])

        cart.reset()
        XCTAssertNil(cart.netPrice)
        XCTAssertNil(cart.grossPrice)
        XCTAssertNil(cart.coupons)
        XCTAssertTrue(cart.items.isEmpty)
    }

    /// Test setting tax and prices in cart (should also affect the contained units).
    func testCartSetPrices() {
        var cart = Cart(with: UUID())
        cart.netPrice = Price(25.0)
        cart.items = [CartUnit(for: UUID(), with: 5),
                      CartUnit(for: UUID(), with: 3)]
        cart.items[0].tax = UnitTax()
        cart.items[0].tax!.category = "food"
        cart.items[0].netPrice = Price(10.0)
        cart.items[1].tax = UnitTax()
        cart.items[1].tax!.category = "some category"
        cart.items[1].netPrice = Price(15.0)
        var rate = TaxRate()
        rate.general = 10.0
        rate.categories["food"] = 12.0
        cart.setPrices(using: rate)

        XCTAssertEqual(cart.items[0].tax!.category, "food")
        TestApproxEqual(cart.items[0].tax!.rate, 12.0)
        TestApproxEqual(cart.items[0].tax!.total.value, 1.2)
        XCTAssertEqual(cart.items[0].grossPrice!.value, 11.2)
        XCTAssertEqual(cart.items[1].tax!.category, "some category")
        TestApproxEqual(cart.items[1].tax!.rate, 10.0)      // defaults to general
        TestApproxEqual(cart.items[1].tax!.total.value, 1.5)
        XCTAssertEqual(cart.items[1].grossPrice!.value, 16.5)
        XCTAssertEqual(cart.grossPrice!.value, 27.7)
    }

    /// Test that the checkout object properly validates the address passed to it.
    func testCheckoutValidation() {
        var accountData = Account()
        let address = Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "bar", city: "baz",
                              province: "blah", country: "bleh", code: "666", label: nil)
        accountData.address = [address]

        var data = CheckoutData()
        data.shippingAddressAt = 0
        XCTAssertNil(data.shippingAddress)
        XCTAssertNil(data.billingAddress)
        try! data.validate(using: accountData)
        XCTAssertNil(data.shippingAddressAt)
        XCTAssertNotNil(data.shippingAddress)
        XCTAssertNil(data.billingAddress)

        data.billingAddressAt = 0
        try! data.validate(using: accountData)
        XCTAssertNotNil(data.billingAddress)
        XCTAssertNil(data.billingAddressAt)

        var tests = [(CheckoutData, ServiceError)]()
        data = CheckoutData()
        data.shippingAddressAt = 1
        tests.append((data, .invalidAddress))
        data.billingAddressAt = 1
        tests.append((data, .invalidAddress))

        data = CheckoutData()
        data.shippingAddressAt = nil
        tests.append((data, .invalidCheckoutData))

        data.shippingAddress = Address()
        tests.append((data, .invalidAddressName))

        data = CheckoutData()
        data.billingAddress = Address()
        tests.append((data, .invalidAddressName))

        for (data, error) in tests {
            do {
                var data = data
                try data.validate(using: accountData)
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }
}
