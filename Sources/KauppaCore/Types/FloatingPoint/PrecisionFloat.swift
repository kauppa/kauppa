import Foundation

/// Wrapper around `Float` for appropriate rounding. This rounds the value to the specified decimal
/// places before encoding and allows strings, integers and floats for values while decoding.
/// This is useful for measurements, prices and percentages.
public class PrecisionFloat<C: Rounding>: Mappable, Equatable {

    public private(set) var value: Float

    /// Initialize an instance from a `Float` value.
    public init(_ value: Float) {
        self.value = value
    }

    /// Initialize an empty value of this type.
    public convenience required init() {
        self.init(Float())
    }

    /// Initialize a value from string.
    public convenience required init?(_ string: String) {
        if let value = Float(string) {
            self.init(value)
        } else {
            return nil
        }
    }

    /* Encoding and decoding */

    public convenience required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Custom decoding which allows strings, integers and floats.
        if let string = try? container.decode(String.self) {
            guard let float = Float(string) else {
                throw DecodingError.dataCorruptedError(in: container,
                                                       debugDescription: "Cannot parse float from string")
            }

            self.init(float)
            return
        } else if let int = try? container.decode(UInt32.self) {
            self.init(Float(int))
            return
        }

        let float = try Float(from: decoder)
        self.init(float)
    }

    public func encode(to encoder: Encoder) throws {
        // Round the float to two decimal places before encoding.
        let rounded = String(format: "%.\(C.numberOfPlaces)f", value)
        try rounded.encode(to: encoder)
    }

    /* Comparing operators */

    public static func <(lhs: PrecisionFloat, rhs: PrecisionFloat) -> Bool {
        return lhs.value < rhs.value
    }

    public static func >(lhs: PrecisionFloat, rhs: PrecisionFloat) -> Bool {
        return lhs.value > rhs.value
    }

    public static func >=(lhs: PrecisionFloat, rhs: PrecisionFloat) -> Bool {
        return lhs.value >= rhs.value
    }

    public static func <=(lhs: PrecisionFloat, rhs: PrecisionFloat) -> Bool {
        return lhs.value <= rhs.value
    }

    /* Non-mutating arithmetic operators */

    public static func *(lhs: PrecisionFloat, rhs: PrecisionFloat) -> PrecisionFloat {
        return PrecisionFloat(lhs.value * rhs.value)
    }

    public static func /(lhs: PrecisionFloat, rhs: PrecisionFloat) -> PrecisionFloat {
        return PrecisionFloat(lhs.value / rhs.value)
    }

    public static func -(lhs: PrecisionFloat, rhs: PrecisionFloat) -> PrecisionFloat {
        return PrecisionFloat(lhs.value - rhs.value)
    }

    public static func +(lhs: PrecisionFloat, rhs: PrecisionFloat) -> PrecisionFloat {
        return PrecisionFloat(lhs.value + rhs.value)
    }

    /* Mutating arithmetic operators */

    public static func *=(lhs: inout PrecisionFloat, rhs: PrecisionFloat) {
        lhs.value *= rhs.value
    }

    public static func /=(lhs: inout PrecisionFloat, rhs: PrecisionFloat) {
        lhs.value /= rhs.value
    }

    public static func +=(lhs: inout PrecisionFloat, rhs: PrecisionFloat) {
        lhs.value += rhs.value
    }

    public static func -=(lhs: inout PrecisionFloat, rhs: PrecisionFloat) {
        lhs.value -= rhs.value
    }

    /* Equality */

    public static func ==(lhs: PrecisionFloat, rhs: PrecisionFloat) -> Bool {
        return lhs.value == rhs.value
    }
}
