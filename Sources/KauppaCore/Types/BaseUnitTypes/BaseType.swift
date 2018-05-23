/// Basic types supported by Kauppa.
public enum BaseType: String, Codable {
    case area
    case boolean
    case currency
    case enum_       = "enum"
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
            case .string, .enum_:
                return value
            case .boolean:
                return Bool(value)
            case .currency:
                return Price(value)
            case .number:
                return Int32(value)
            default:
                return Float(value)
        }
    }

    /// Parse the given unit into Swift representable value.
    public func parse(unit: String) -> Unit? {
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
