import Foundation
import XCTest

import KauppaCore

class TestDatabase: XCTestCase {
    static var allTests: [(String, (TestDatabase) -> () throws -> Void)] {
        return [
            ("Test implemented getValue", testRowImplemented),
            ("Test unimplemented getValue", testRowUnimplemented),
        ]
    }

    // This is a test for how a `Database` and `DatabaseRow` implementor should work.
    // It essentially tests that the implemented `getValue` method is called instead
    // of the default version.
    func testRowImplemented() {
        // Here, we make use of `TestDatabaseRow` which declares that `ValueConvertible`
        // is the `Codable` protocol, and so there's a `getValue` method that returns objects
        // conforming to that protocol.
        struct TestDatabaseRow: DatabaseRow {
            typealias ValueConvertible = Codable

            // Implement the method with the protocol bound. The default method throws
            // `ServiceError.getValueUnimplemented` whereas here, we're throwing
            // `ServiceError.valueDecodingError` - if we get this while trying to get
            // a value from the row, then we're good!
            public func getValue<T: Codable>(for key: String) throws -> T {
                throw ServiceError.valueDecodingError
            }
        }

        // Then, we use this `NoOpTestDatabase` class to use the `DatabaseRow` implementor.
        // On calling `execute`, it returns an instance of the row in the array.
        class NoOpTestDatabase: Database {
            typealias ValueConvertible = Codable
            typealias Row = TestDatabaseRow

            public required init(for url: URL, with tlsConfig: TLSConfig?) throws {}

            public func execute(query: String, with parameters: [ValueConvertible]) throws -> [Row] {
                return [TestDatabaseRow()]
            }
        }

        let database = try! NoOpTestDatabase(for: URL(string: "http://foo.bar")!, with: nil)
        let rows = try! database.execute(query: "", with: [])

        do {
            let _: String = try rows[0].getValue(for: "foobar")
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .valueDecodingError)
        }
    }

    // Test that getting value from a `DatabaseRow` type throws unimplemented error by default.
    func testRowUnimplemented() {
        // A database row type without any `getValue` implementation.
        struct TestDatabaseRow: DatabaseRow {
            typealias ValueConvertible = Codable
        }

        // Same database class using the row type.
        class NoOpTestDatabase: Database {
            typealias ValueConvertible = Codable
            typealias Row = TestDatabaseRow

            public required init(for url: URL, with tlsConfig: TLSConfig?) throws {}

            public func execute(query: String, with parameters: [ValueConvertible]) throws -> [Row] {
                return [TestDatabaseRow()]
            }
        }

        let database = try! NoOpTestDatabase(for: URL(string: "http://foo.bar")!, with: nil)
        let rows = try! database.execute(query: "", with: [])

        do {
            let _: String = try rows[0].getValue(for: "foobar")
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .getValueUnimplemented)
        }
    }
}
