import PostgreSQL

/// Row type used by the `PostgresDatabase` (returned after executing queries).
public typealias PostgreDatabaseRow = [PostgreSQLColumn: PostgreSQLData]

extension Dictionary: DatabaseRow
    where Key == PostgreSQLColumn, Value == PostgreSQLData
{
    public typealias ValueConvertible = PostgreSQLDataConvertible

    /// Override for the default `getValue` implementation.
    public func getValue<T: ValueConvertible>(for key: String) throws -> T {
        for (field, value) in self {
            if field.name == key {
                do {
                    return try value.decode(T.self)
                } catch {
                    throw ServiceError.valueDecodingError
                }
            }
        }

        throw ServiceError.missingField
    }
}
