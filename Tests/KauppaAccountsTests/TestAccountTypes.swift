import Foundation
import XCTest

import KauppaCore
@testable import KauppaAccountsModel

struct TestStruct<T: Mappable>: Mappable {
    let value: T
}

class TestAccountTypes: XCTestCase {
    static var allTests: [(String, (TestAccountTypes) -> () throws -> Void)] {
        return [
            ("Test address", testAddress),
            ("Test verifiable types", testVerifiables),
            ("Test account data", testAccountData),
        ]
    }

    /// Function to decode the given JSON string to target `T` and `XCTAssertEqual`
    /// the decoded value against the given value.
    func decodeAssertEqual<T>(_ string: String, _ value: T)
        where T: Mappable, T: Equatable
    {
        let data = string.data(using: .utf8)!
        let item = try! JSONDecoder().decode(TestStruct<T>.self, from: data)
        XCTAssertEqual(item.value, value)
    }

    /// Test that the verifiable types properly decode.
    func testVerifiables() {
        decodeAssertEqual("{\"value\": \"abc@xyz.com\"}", Email("abc@xyz.com"))
        decodeAssertEqual("{\"value\": \"number\"}", Phone("number"))
    }

    /// Test for proper errors from `Address` object when during validation.
    func testAddress() {
        let tests = [
            (Address(firstName: "", lastName: nil, line1: "foo", line2: "", city: "baz", province: "blah",
                     country: "bleh", code: "666", label: nil), ServiceError.invalidAddressName),
            (Address(firstName: "foobar", lastName: nil, line1: "", line2: "", city: "baz", province: "blah",
                     country: "bleh", code: "666", label: nil), ServiceError.invalidAddressLineData),
            (Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "", city: "", province: "blah",
                     country: "bleh", code: "666", label: nil), ServiceError.invalidAddressCity),
            (Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "", city: "baz", province: "",
                     country: "bleh", code: "666", label: nil), ServiceError.invalidAddressProvince),
            (Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "", city: "baz", province: "blah",
                     country: "", code: "666", label: nil), ServiceError.invalidAddressCountry),
            (Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "", city: "baz", province: "blah",
                     country: "bleh", code: "", label: nil), ServiceError.invalidAddressCode),
            (Address(firstName: "foobar", lastName: nil, line1: "foo", line2: "", city: "baz", province: "blah",
                     country: "bleh", code: "666", label: ""), ServiceError.invalidAddressLabel)
        ]

        for (testCase, error) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }

    /// Test for possible errors in `AccountData`
    func testAccountData() {
        var data = Account()
        var tests = [(Account, ServiceError)]()
        data.name = ""
        tests.append((data, ServiceError.invalidAccountName))
        data.name = "foo"
        tests.append((data, ServiceError.accountEmailRequired))     // empty email list
        data.emails = ArraySet([Email("bleh")])
        tests.append((data, ServiceError.invalidAccountEmail))
        data.emails = ArraySet([Email("abc@xyz.com")])
        data.phoneNumbers = ArraySet([Phone("")])
        tests.append((data, ServiceError.invalidAccountPhone))

        for (testCase, error) in tests {
            do {
                try testCase.validate()
                XCTFail()
            } catch let err {
                XCTAssertEqual(err as! ServiceError, error)
            }
        }
    }
}
