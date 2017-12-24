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

    /// Get the corresponding Swift type for this type's value.
    public func swiftBaseType() -> Any.Type {
        switch self {
            case .string:
                return String.self
            case .number:
                return UInt32.self
            default:
                return Float32.self
        }
    }

    /// Get the corresponding unit type for this type's unit (if it's required).
    public func swiftUnitType() -> Any.Type? {
        switch self {
            case .area:
                return Area.self
            case .currency:
                return Currency.self
            case .length:
                return Length.self
            case .mass:
                return Weight.self
            case .temperature:
                return Temperature.self
            case .volume:
                return Volume.self
            default:
                return nil
        }
    }
}
