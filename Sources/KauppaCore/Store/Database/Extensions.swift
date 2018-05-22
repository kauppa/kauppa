import SwiftKuery

/// Add extension for building array types that have a supported data type.
public class PostgresArray<T: SQLDataType>: SQLDataType {
    public static func create(queryBuilder: QueryBuilder) -> String {
        return "\(T.create(queryBuilder: queryBuilder))[]"
    }
}
