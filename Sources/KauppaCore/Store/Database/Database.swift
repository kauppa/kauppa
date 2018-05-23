import Foundation

import Loki
import SwiftKuery

/// A generic database to be implemented by any database client used in the stores
/// throughout Kauppa services.
public protocol Database {
    /// Alias for the protocol used to convert the database types to and fro.
    associatedtype ValueConvertible
    /// Alias for the `DatabaseRow` implementor (returned after executing a query).
    associatedtype Row: DatabaseRow

    /// The query builder instance for this database.
    var queryBuilder: QueryBuilder { get }

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
    @discardableResult func execute(queryString query: String, with parameters: [ValueConvertible]) throws -> [Row]
}

extension Database {
    /// Build and execute the given query in the database with parameter values that implement the
    /// `ValueConvertible` (alias) protocol.
    ///
    /// - Parameters:
    ///   - The query (implementing `Buildable`) to be executed.
    ///   - with: The list of parameter values used in the query.
    /// - Returns: List of `Row` (alias. `DatabaseRow`) implementors.
    /// - Throws: `ServiceError` if the query can't be built or if there was a failure in execution.
    @discardableResult public func execute(query: Buildable, with parameters: [Any]) throws -> [Row] {
        guard let parameters = parameters as? [ValueConvertible] else {
            Loki.error("Parameters cannot be casted to known types. This occurs only when some values" +
                       " don't implement the convertible protocol offered by the database driver.")
            throw ServiceError.invalidQuery
        }

        var string = ""
        do {
            string = try query.build(queryBuilder: queryBuilder)
            Loki.debug("Executing: \(string)")
        } catch let err {
            Loki.error("Error building query: \(err)")
            throw ServiceError.invalidQuery
        }

        do {
            return try execute(queryString: string, with: parameters)
        } catch let err as ServiceError {
            throw err
        } catch let err {
            Loki.error("Unknown error has propagated from driver: \(err)" +
                       "\nPlease handle that as a domain error.")
            throw ServiceError.errorExecutingQuery
        }
    }

    /// Execute SQL statements from a file. This is useful for pre-deployment scripts.
    /// Note that this assumes that the individual statements end with a semicolon.
    ///
    /// - Parameters:
    ///   - file: The path of the file to be executed.
    /// - Throws: `ServiceError` on failure.
    public func execute(file path: String) throws {
        var data = ""
        do {
            data = try String(contentsOfFile: path, encoding: .utf8)
        } catch let err {
            Loki.error("Error reading script \(path): \(err)")
            throw ServiceError.errorReadingFile
        }

        var currentLine = ""
        for line in data.components(separatedBy: .newlines) {
            let line = line.trim()
            if line.isEmpty {   // This is an empty line.
                continue
            }

            currentLine += line
            if line.hasSuffix(";") {
                try execute(queryString: currentLine, with: [])
                currentLine = ""
            }
        }
    }
}
