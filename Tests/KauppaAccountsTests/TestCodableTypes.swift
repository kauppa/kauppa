import Foundation
import XCTest

import KauppaCore
@testable import KauppaAccountsModel

class TestCodableTypes: XCTestCase {
    static var allTests: [(String, (TestCodableTypes) -> () throws -> Void)] {
        return [
            ("Test address kind", testAddressKind),
        ]
    }

    func testAddressKind() {
        struct TestStruct: Mappable {
            let kind: AddressKind
        }

        let tests = [
            ("{\"kind\": \"home\"}", AddressKind.home),
            ("{\"kind\": \"work\"}", AddressKind.work),
            ("{\"kind\": \"foobar\"}", AddressKind.custom("foobar"))
        ]

        for (string, kind) in tests {
            let data = string.data(using: .utf8)!
            let value = try! JSONDecoder().decode(TestStruct.self, from: data)
            XCTAssertEqual(value.kind, kind)
        }
    }
}
