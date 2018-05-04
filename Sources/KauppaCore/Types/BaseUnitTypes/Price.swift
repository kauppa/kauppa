import Foundation

/// Wrapper around `Float` for manipulating price. This rounds the value to 2 decimal places
/// before encoding and allows strings, integers and floats for values while decoding.
public class Price: Mappable {

    public private(set) var value: Float

    /// Initialize an empty value of this type.
    public init() {
        self.value = Float()
    }

    /// Initialize an instance from a `Float` value.
    public init(_ value: Float) {
        self.value = value
    }

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
        let rounded = String(format: "%.2f", value)
        try rounded.encode(to: encoder)
    }
}

/* Required operator methods for float manipulations. */

extension Price {
    // Comparing operators

    public static func <(lhs: Price, rhs: Price) -> Bool {
        return lhs.value < rhs.value
    }

    public static func >(lhs: Price, rhs: Price) -> Bool {
        return lhs.value > rhs.value
    }

    public static func >=(lhs: Price, rhs: Price) -> Bool {
        return lhs.value >= rhs.value
    }

    public static func <=(lhs: Price, rhs: Price) -> Bool {
        return lhs.value <= rhs.value
    }

    // Non-mutating arithmetic operators

    public static func *(lhs: Price, rhs: Price) -> Price {
        return Price(lhs.value * rhs.value)
    }

    public static func /(lhs: Price, rhs: Price) -> Price {
        return Price(lhs.value / rhs.value)
    }

    public static func -(lhs: Price, rhs: Price) -> Price {
        return Price(lhs.value - rhs.value)
    }

    public static func +(lhs: Price, rhs: Price) -> Price {
        return Price(lhs.value + rhs.value)
    }

    // Mutating arithmetic operators.

    public static func *=(lhs: inout Price, rhs: Price) {
        lhs.value *= rhs.value
    }

    public static func /=(lhs: inout Price, rhs: Price) {
        lhs.value /= rhs.value
    }

    public static func +=(lhs: inout Price, rhs: Price) {
        lhs.value += rhs.value
    }

    public static func -=(lhs: inout Price, rhs: Price) {
        lhs.value -= rhs.value
    }
}

extension Price: Equatable {
    public static func ==(lhs: Price, rhs: Price) -> Bool {
        return lhs.value == rhs.value
    }
}
