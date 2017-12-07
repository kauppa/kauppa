import Foundation

import KauppaCore

/// An address representation.
public struct Address: Mappable, Hashable {
    /// Address line 1
    public let line1: String
    /// Address line 2
    public let line2: String
    /// City
    public let city: String
    /// Country
    public let country: String
    /// Postal/ZIP code
    public let code: UInt32
    /// Label for this address.
    public let kind: AddressKind

    public var hashValue: Int {
        return line1.hashValue ^ line2.hashValue ^ city.hashValue ^
               country.hashValue ^ code.hashValue
    }

    public static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.line1 == rhs.line1 &&
               lhs.line2 == rhs.line2 &&
               lhs.city == rhs.city &&
               lhs.country == rhs.country &&
               lhs.code == rhs.code
    }
}
