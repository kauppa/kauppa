import Foundation

/// A generic database to be implemented by any database client used in the stores
/// throughout Kauppa services.
public protocol Database {
    /// Alias for the protocol used to convert the database types to and fro.
    associatedtype ValueConvertible
    /// Alias for the `DatabaseRow` implementor (returned after executing a query).
    associatedtype Row: DatabaseRow

    /// Initialize the database with an URL and an optional TLS configuration.
    ///
    /// - Parameters:
    ///   - url: The `URL` for the database service.
    ///   - tlsConfig: The (optional) `TLSConfig` for the client.
    /// - Throws: `ServiceError` on failure.
    init(for url: URL, with tlsConfig: TLSConfig?) throws

    /// Execute the given query in the database with parameter values that implement the
    /// `ValueConvertible` (alias) protocol.
    ///
    /// - Parameters:
    ///   - query: The query string.
    ///   - with: The list of parameter values used in the query.
    /// - Returns: List of `Row` (alias. `DatabaseRow`) implementors.
    /// - Throws: `ServiceError` on failure.
    @discardableResult func execute(query: String, with parameters: [ValueConvertible]) throws -> [Row]
}
