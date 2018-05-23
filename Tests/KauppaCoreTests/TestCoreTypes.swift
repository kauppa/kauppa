import Foundation

import XCTest

@testable import KauppaCore
@testable import TestTypes

class TestCoreTypes: XCTestCase {
    static var allTests: [(String, (TestCoreTypes) -> () throws -> Void)] {
        return [
            ("Test random alpha-numeric string", testRandomAlphaNum),
            ("Test price JSON encoding/decoding", testPriceCoding),
        ]
    }

    // Test that randomly generated alphanumeric values are almost random.
    func testRandomAlphaNum() {
        let string1 = String.randomAlphaNumeric(ofLength: 2)
        let string2 = String.randomAlphaNumeric(ofLength: 2)
        XCTAssertTrue(string1 != string2)
    }

    // Test JSON encoding/decoding of `Price` values.
    func testPriceCoding() {
        // some edge cases similar to tax applied for some prices.
        let prices = [Price(27.25 * 0.3), Price(9.75 * 0.07), Price(4.5 * 0.09)]
        let data1 = try! JSONEncoder().encode(MappableArray(for: prices))
        let expectation = MappableArray(for: ["8.18", "0.68", "0.41"])
        let data2 = try! JSONEncoder().encode(expectation)
        XCTAssertEqual(data1, data2)
    }
}
