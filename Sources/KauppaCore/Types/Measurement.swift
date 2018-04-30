/// Any measurable quantity
public struct UnitMeasurement<T: Codable>: Codable {
    public var value: Double
    public var unit: T

    /// Initialize an instance with a value and an unit.
    ///
    /// - Parameters:
    ///   - value: The value of this quantity.
    ///   - unit: The unit of this quantity.
    public init(value: Double, unit: T) {
        self.value = value
        self.unit = unit
    }
}

/// An object to represent the dimensions of a product. All are length measurement
/// properties and are optional.
public struct Dimensions: Codable {
    /// Length of the product (if any)
    public var length: UnitMeasurement<Length>? = nil
    /// Width of the product (if any)
    public var width: UnitMeasurement<Length>? = nil
    /// Height of the product (if any)
    public var height: UnitMeasurement<Length>? = nil
}
