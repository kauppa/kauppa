import Foundation

import KauppaCore

/// An address representation.
public struct Address: Mappable {
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
}
