import Foundation
import XCTest

import KauppaCore
@testable import KauppaAccountsModel

class TestAccountTypes: XCTestCase {
    static var allTests: [(String, (TestAccountTypes) -> () throws -> Void)] {
        return [
            ("Test address kind", testAddressKind),
            ("Test address", testAddress),
            ("Test account data", testAccountData),
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

    func testAddress() {
        let tests = [
            (Address(line1: "", line2: "", city: "baz", country: "bleh", code: "666", kind: nil), "line data"),
            (Address(line1: "foo", line2: "", city: "", country: "bleh", code: "666", kind: nil), "city"),
            (Address(line1: "foo", line2: "", city: "baz", country: "", code: "666", kind: nil), "country"),
            (Address(line1: "foo", line2: "", city: "baz", country: "bleh", code: "", kind: nil), "code"),
            (Address(line1: "foo", line2: "", city: "baz", country: "bleh", code: "666", kind: .custom("")), "tag")
        ]

        for (testCase, source) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                let e = err as! AccountsError
                XCTAssertEqual(e.localizedDescription, "Invalid \(source) in address")
            }
        }
    }

    func testAccountData() {
        var data = AccountData()
        var tests = [(AccountData, AccountsError)]()
        data.name = ""
        tests.append((data, AccountsError.invalidName))
        data.name = "foo"
        tests.append((data, AccountsError.emailRequired))   // empty email list
        data.emails = ArraySet(["bleh"])
        tests.append((data, AccountsError.invalidEmail))
        data.emails = ArraySet(["abc@xyz.com"])
        data.phone = ""
        tests.append((data, AccountsError.invalidPhone))

        for (testCase, error) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! AccountsError, error)
            }
        }
    }
}
