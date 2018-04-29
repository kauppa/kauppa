import Foundation
import XCTest

import KauppaCore
import KauppaCartModel
@testable import KauppaTaxModel

class TestCartTypes: XCTestCase {
    static var allTests: [(String, (TestCartTypes) -> () throws -> Void)] {
        return [
            ("Test cart reset", testCartReset),
            ("Test cart price setting", testCartSetPrices),
            ("Test cart unit reset", testCartUnitReset),
            ("Test cart unit price setting", testCartUnitSetPrices)
        ]
    }

    /// Check that reseting cart unit properly resets the necessary properties.
    func testCartUnitReset() {
        var unit = CartUnit(for: UUID(), with: 5)
        unit.tax = UnitTax()
        unit.tax!.category = "something"
        unit.tax!.rate = 25.0
        unit.tax!.total = UnitMeasurement(value: 5.0, unit: Currency.usd)
        unit.netPrice = UnitMeasurement(value: 5.0, unit: Currency.usd)
        unit.grossPrice = UnitMeasurement(value: 6.25, unit: Currency.usd)

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
        unit.netPrice = UnitMeasurement(value: 5.0, unit: Currency.usd)
        var rate = TaxRate()
        rate.categories["drink"] = 10.0
        unit.setPrices(using: rate)

        XCTAssertEqual(unit.tax!.category!, "drink")
        XCTAssertEqual(unit.tax!.total.value, 0.5)
        XCTAssertEqual(unit.tax!.rate, 10.0)
        XCTAssertEqual(unit.grossPrice!.value, 5.5)
    }

    /// Check that reseting cart properly sets all internal properties to `nil`.
    func testCartReset() {
        var cart = Cart(with: UUID())
        cart.items.append(CartUnit(for: UUID(), with: 5))
        cart.netPrice = UnitMeasurement(value: 5.0, unit: Currency.usd)
        cart.grossPrice = UnitMeasurement(value: 5.5, unit: Currency.usd)
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
        cart.netPrice = UnitMeasurement(value: 25.0, unit: Currency.usd)
        cart.items = [CartUnit(for: UUID(), with: 5),
                      CartUnit(for: UUID(), with: 3)]
        cart.items[0].tax = UnitTax()
        cart.items[0].tax!.category = "food"
        cart.items[0].netPrice = UnitMeasurement(value: 10.0, unit: Currency.usd)
        cart.items[1].tax = UnitTax()
        cart.items[1].tax!.category = "some category"
        cart.items[1].netPrice = UnitMeasurement(value: 15.0, unit: Currency.usd)
        var rate = TaxRate()
        rate.general = 10.0
        rate.categories["food"] = 12.0
        cart.setPrices(using: rate)

        XCTAssertEqual(cart.items[0].tax!.category, "food")
        XCTAssertEqual(cart.items[0].tax!.rate, 12.0)
        XCTAssertEqual(cart.items[0].tax!.total.value, 1.2)
        XCTAssertEqual(cart.items[0].grossPrice!.value, 11.2)
        XCTAssertEqual(cart.items[1].tax!.category, "some category")
        XCTAssertEqual(cart.items[1].tax!.rate, 10.0)            // defaults to general
        XCTAssertEqual(cart.items[1].tax!.total.value, 1.5)
        XCTAssertEqual(cart.items[1].grossPrice!.value, 16.5)
        XCTAssertEqual(cart.grossPrice!.value, 27.7)
    }
}
