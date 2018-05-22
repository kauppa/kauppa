import SwiftKuery

/// Represents a table in the database.
open class DatabaseModel: Table {

    /// Returns: All `Column` values in this table.
    public var allColumns: [Column] {
        return columns
    }

    /// Creates parameters for columns with the given values. This checks that the values
    /// aren't `nil` and ignores the corresponding columns if they are. It finally returns
    /// the modified columns, values and parameters lists.
    ///
    /// - Parameter:
    ///   - for: The list of `Column` identifiers.
    ///   - with: The list of optional values.
    /// - Returns: A tuple containing checked columns, values and parameter placeholders (in that order).
    public func createParameters(for columns: [Column], with values: [Any?]) -> ([Column], [Any], [Parameter]) {
        var cols = [Column]()
        var vals = [Any]()
        var params = [Parameter]()

        for (column, value) in zip(columns, values) {
            if (value as OptionalType).isNone() {
                continue
            }

            cols.append(column)
            vals.append(value!)
            params.append(Parameter())
        }

        return (cols, vals, params)
    }

    /// Creates parameters for all the columns with the given values. This calls the above
    /// function with `allColumns` property.
    ///
    /// - Parameter:
    ///   - for: The list of `Column` identifiers.
    ///   - with: The list of optional values.
    /// - Returns: A tuple containing checked columns, values and parameter placeholders (in that order).
    public func createParameters(with values: [Any?]) -> ([Column], [Any], [Parameter]) {
        return createParameters(for: allColumns, with: values)
    }
}
