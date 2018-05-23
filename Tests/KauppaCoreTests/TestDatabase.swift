import Foundation
import XCTest

import KauppaCore
import SwiftKuery

class TestDatabase: XCTestCase {
    static var allTests: [(String, (TestDatabase) -> () throws -> Void)] {
        return [
            ("Test implemented getValue", testRowImplemented),
            ("Test unimplemented getValue", testRowUnimplemented),
            ("Test parameter building", testParameterBuilding),
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
            public func getValue<T: Codable>(forKey: String) throws -> T {
                throw ServiceError.valueDecodingError
            }
        }

        // Then, we use this `NoOpTestDatabase` class to use the `DatabaseRow` implementor.
        // On calling `execute`, it returns an instance of the row in the array.
        class NoOpTestDatabase: Database {
            typealias ValueConvertible = Codable
            typealias Row = TestDatabaseRow

            public var queryBuilder = QueryBuilder()

            public required init(for url: URL, with tlsConfig: TLSConfig?) throws {}

            public func execute(queryString: String, with parameters: [ValueConvertible]) throws -> [Row] {
                return [TestDatabaseRow()]
            }
        }

        let database = try! NoOpTestDatabase(for: URL(string: "http://foo.bar")!, with: nil)
        let rows = try! database.execute(queryString: "", with: [])

        do {
            let _: String = try rows[0].getValue(forKey: "foobar")
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

            public var queryBuilder = QueryBuilder()

            public required init(for url: URL, with tlsConfig: TLSConfig?) throws {}

            public func execute(queryString: String, with parameters: [ValueConvertible]) throws -> [Row] {
                return [TestDatabaseRow()]
            }
        }

        let database = try! NoOpTestDatabase(for: URL(string: "http://foo.bar")!, with: nil)
        let rows = try! database.execute(queryString: "", with: [])

        do {
            let _: String = try rows[0].getValue(forKey: "foobar")
            XCTFail()
        } catch let err {
            XCTAssertEqual(err as! ServiceError, .getValueNotImplemented)
        }
    }

    // Test that table models properly generate parameters based on the given values.
    func testParameterBuilding() {
        class TestTable: DatabaseModel<String> {
            let column1 = Column("foo", String.self)
            let column2 = Column("bar", Float.self)
            let column3 = Column("baz", PostgresArray<UUID>.self)
            let column4 = Column("boo", Int32.self)
            let column5 = Column("yay", PostgresArray<Bool>.self)
        }

        let table = TestTable()
        let columns = [table.column1, table.column2, table.column3, table.column4, table.column5]
        // Check that the order of columns is the same.
        XCTAssertEqual(table.allColumns.map { $0.name }, columns.map { $0.name })

        let values: [Any?] = ["booya", nil, [UUID()], nil, nil]
        let (cols, vals, params) = table.createParameters(for: columns, with: values)
        XCTAssertEqual(cols.count, 2)
        XCTAssertEqual(vals.count, 2)
        XCTAssertEqual(params.count, 2)
    }
}
