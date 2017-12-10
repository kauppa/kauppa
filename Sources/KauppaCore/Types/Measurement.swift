/// Any measurable quantity
public struct UnitMeasurement<T: Codable>: Codable {
    public var value: Double
    public var unit: T

    public init(value: Double, unit: T) {
        self.value = value
        self.unit = unit
    }
}

/// Size values (length, width and height - all optional)
public struct Size: Codable {
    public var height: UnitMeasurement<Length>? = nil
    public var length: UnitMeasurement<Length>? = nil
    public var width: UnitMeasurement<Length>? = nil
}
