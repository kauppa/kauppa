import SwiftKuery

/// A buldable table solely for executing table queries. The actual `Table` uses a
/// different method to build the query and we're adding a wrapper.
public class BuildableTable: Buildable {

    private let table: Table
    // FIXME: This should be supported by `Table` - fork or PR
    private let ifNotExists: Bool

    /// Initialize an instance with a table.
    ///
    /// - Parameters:
    ///   - for: The `Table` implementor.
    ///   - ifNotExists: Flag to create only when the table doesn't exist.
    public init(for table: Table, ifNotExists: Bool = true) {
        self.table = table
        self.ifNotExists = ifNotExists
    }

    public func build(queryBuilder: QueryBuilder) throws -> String {
        let string = try table.description(connection: NoOpConnection(with: queryBuilder))
        return string.replacingOccurrences(of: "CREATE TABLE", with: "CREATE TABLE IF NOT EXISTS")
    }
}
