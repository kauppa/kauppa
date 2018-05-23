import SwiftKuery

/// Represents a table model in the database.
open class DatabaseModel<Model: Mappable>: Table {
    /// Default implementation to get all the values from the model. Note that this should
    /// contain all the fields (in the same order) in the table model.
    ///
    /// - Parameters
    ///   - from: The associated `Model`
    /// - Returns: The list of `Model` properties.
    open func values(from model: Model) -> [Any?] {
        return []
    }

    /// Default implementation for creating a new model from the row result
    /// from the database.
    ///
    /// - Parameters:
    ///   - from: The `DatabaseRow` to be used for creating the model.
    /// - Throws: `ServiceError` if this method wasn't implemented or if there was a failure.
    /// - Returns: The newly created `Model`
    open func create<R: DatabaseRow>(from row: R) throws -> Model {
        throw ServiceError.modelCreationNotImplemented
    }

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
