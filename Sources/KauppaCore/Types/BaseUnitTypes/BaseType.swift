/// Basic types supported by Kauppa.
public enum BaseType: String, Codable {
    case area
    case currency
    case length
    case mass
    case number
    case string
    case temperature
    case volume

    /// Check whether this type needs an unit.
    public var hasUnit: Bool {
        switch self {
            case .area, .currency, .length, .mass, .temperature, .volume:
                return true
            default:
                return false
        }
    }

    /// Parse the given value into Swift representable value.
    public func parse(value: String) -> Any? {
        switch self {
            case .string:
                return value
            case .number:
                return UInt32(value)
            default:
                return Float32(value)
        }
    }

    /// Parse the given unit into Swift representable value.
    public func parse(unit: String) -> Any? {
        switch self {
            case .area:
                return Area(rawValue: unit)
            case .currency:
                return Currency(rawValue: unit)
            case .length:
                return Length(rawValue: unit)
            case .mass:
                return Weight(rawValue: unit)
            case .temperature:
                return Temperature(rawValue: unit)
            case .volume:
                return Volume(rawValue: unit)
            default:
                return nil
        }
    }
}
