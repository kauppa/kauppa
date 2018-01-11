import Foundation

import KauppaCore

/// Type to represent an email ID.
public typealias Email = VerifiableType<String>

/// Type to represent a phone number.
public typealias Phone = VerifiableType<String>

/// Wrapper type for values that require explicit verification. This is useful
/// for emails and phone numbers, which, when changed, requires verification.
///
/// By default, the value is unverified. This type also doesn't affect the JSON
/// encoding/decoding - it just serializes/deserializes like the actual value.
/// On the other hand, it "should" affect the store, so that the flag persists.
///
/// NOTE: It's better to alias this wrapper around your type and use it elsewhere.
///
/// **Example:**
///
/// ```
/// public typealias Email = VerifiableType<String>
/// ```
///
public struct VerifiableType<T>: Mappable, Hashable
    where T: Mappable, T: Hashable
{
    /// Value wrapped by this type.
    public let value: T
    /// Flag to indicate whether this type has been verified.
    public var isVerified = false

    public init(_ value: T) {
        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        self.value = try T(from: decoder)
    }

    public var hashValue: Int {
        return value.hashValue
    }

    public static func ==(lhs: VerifiableType, rhs: VerifiableType) -> Bool {
        return lhs.value == rhs.value
    }
}
