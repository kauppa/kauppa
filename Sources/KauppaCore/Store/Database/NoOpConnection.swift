import SwiftKuery

/// A No-op connection that does nothing. This is a workaround to get the `Table` to build
/// query using a custom query builder. The `Table` builds the actual query only when we
/// pass a `Connection` implementor.
public class NoOpConnection: Connection {

    public var queryBuilder: QueryBuilder

    /// Initialize an instance with a custom query builder.
    ///
    /// - Parameters:
    ///   - with: The `QueryBuilder`
    public init(with builder: QueryBuilder) {
        queryBuilder = builder
    }

    public func connect(onCompletion: (QueryError?) -> ()) {}

    public func closeConnection() {}

    public var isConnected: Bool { return false }

    public func execute(query: Query, onCompletion: @escaping ((QueryResult) -> ())) {}

    public func execute(_ raw: String, onCompletion: @escaping ((QueryResult) -> ())) {}

    public func execute(query: Query, parameters: [Any?], onCompletion: @escaping ((QueryResult) -> ())) {}

    public func execute(_ raw: String, parameters: [Any?], onCompletion: @escaping ((QueryResult) -> ())) {}

    public func execute(query: Query, parameters: [String:Any?], onCompletion: @escaping ((QueryResult) -> ())) {}

    public func execute(_ raw: String, parameters: [String:Any?], onCompletion: @escaping ((QueryResult) -> ())) {}

    public func prepareStatement(_ query: Query) throws -> PreparedStatement {
        throw ServiceError.connectionError
    }

    public func prepareStatement(_ raw: String) throws -> PreparedStatement {
        throw ServiceError.connectionError
    }

    public func execute(preparedStatement: PreparedStatement, onCompletion: @escaping ((QueryResult) -> ())) {}

    public func execute(preparedStatement: PreparedStatement, parameters: [Any?], onCompletion: @escaping ((QueryResult) -> ())) {}

    public func execute(preparedStatement: PreparedStatement, parameters: [String:Any?], onCompletion: @escaping ((QueryResult) -> ())) {}

    public func release(preparedStatement: PreparedStatement, onCompletion: @escaping ((QueryResult) -> ())) {}

    public func descriptionOf(query: Query) throws -> String { return "" }

    public func startTransaction(onCompletion: @escaping ((QueryResult) -> ())) {}

    public func commit(onCompletion: @escaping ((QueryResult) -> ())) {}

    public func rollback(onCompletion: @escaping ((QueryResult) -> ())) {}

    public func create(savepoint: String, onCompletion: @escaping ((QueryResult) -> ())) {}

    public func rollback(to savepoint: String, onCompletion: @escaping ((QueryResult) -> ())) {}

    public func release(savepoint: String, onCompletion: @escaping ((QueryResult) -> ())) {}
}
