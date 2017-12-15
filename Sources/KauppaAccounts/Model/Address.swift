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
    ///
    /// There's no general regex (unlike email).
    /// See the complications here - https://stackoverflow.com/a/7185241/
    public let code: String
    /// Label for this address.
    public let kind: AddressKind

    /// Try some basic validations on the address.
    public func validate() throws {
        if line1.isEmpty {
            throw AccountsError.invalidAddress(.invalidLineData)
        }

        if city.isEmpty {
            throw AccountsError.invalidAddress(.invalidCity)
        }

        if country.isEmpty {
            throw AccountsError.invalidAddress(.invalidCountry)
        }

        if code.isEmpty {
            throw AccountsError.invalidAddress(.invalidCode)
        }

        switch kind {
            case let .custom(s):
                if s.isEmpty {
                    throw AccountsError.invalidAddress(.invalidTag)
                }
            default:
                break
        }
    }

    public var hashValue: Int {
        return line1.hashValue ^ line2.hashValue ^ city.hashValue ^
               country.hashValue ^ code.hashValue
    }

    public static func ==(lhs: Address, rhs: Address) -> Bool {
        return lhs.line1 == rhs.line1 &&
               lhs.line2 == rhs.line2 &&
               lhs.city == rhs.city &&
               lhs.country == rhs.country &&
               lhs.code == rhs.code
    }
}
