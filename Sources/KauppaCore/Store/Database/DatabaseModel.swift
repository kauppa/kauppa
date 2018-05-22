import SwiftKuery

/// Represents a table in the database.
open class DatabaseModel: Table {
    /// Creates parameters for columns with the given values. This checks that the values
    /// aren't `nil` and ignores the corresponding columns if they are. It finally returns
    /// the modified columns, values and parameters lists.
    public func createParameters(for columns: [Column], with values: [Any?]) -> ([Column], [Any], [Parameter]) {
        var cols = [Column]()
        var vals = [Any]()
        var params = [Parameter]()

        for (column, value) in zip(columns, values) {
            if let optional = value as? OptionalType {
                if optional.isNone() {
                    continue
                }
            }

            cols.append(column)
            vals.append(value)
            params.append(Parameter())
        }

        return (cols, vals, params)
    }
}
