import SwiftKuery

/// Protocol for the row type returned by the database client after executing a query.
public protocol DatabaseRow {
    /// Alias for the protocol used to convert the database types to and fro.
    associatedtype ValueConvertible
}

extension DatabaseRow {
    /// Default method for getting value from the row for a given column name.
    /// Note that this is a default implementation. **It always fails!**
    /// Implementors should have a `getValue` method where `T` is constrained to their
    /// own `ValueConvertible` protocol. This way, the new method shadows this default
    /// method and the stores remain loosely coupled from the database clients.
    ///
    /// - Parameters:
    ///   - forKey: The name of the column.
    /// - Returns: The expected value decoded from the returned data.
    /// - Throws: `ServiceError` if there was no implementation, or if it fails.
    public func getValue<T>(forKey key: String) throws -> T {
        throw ServiceError.getValueNotImplemented
    }

    /// Safe method for getting value for a given column. This implicitly calls
    /// `getValue` with the column's name.
    ///
    /// - Parameters:
    ///   - forField: The `Column` identifier.
    /// - Returns: The expected value decoded from the returned data.
    /// - Throws: `ServiceError` on failure.
    public func getValue<T>(forField column: Column) throws -> T {
        return try getValue(forKey: column.name)
    }
}
