import SwiftKuery

/// Add extension for building array types that have a supported data type.
public class PostgresArray<T: SQLDataType>: SQLDataType {
    public static func create(queryBuilder: QueryBuilder) -> String {
        return "\(T.create(queryBuilder: queryBuilder))[]"
    }
}

extension Select {
    /// Convenience initializer for selecting all fields in a table.
    ///
    /// - Parameters:
    ///   - from: The `Table` to be queried.
    public init(from table: Table) {
        self.init(table.columns, from: table)
    }
}
