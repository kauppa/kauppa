import Foundation

import KauppaCore

/// An address representation.
public struct Address: Mappable, Hashable {
    /// Name of the person (associated with this address)
    public let name: String
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
    public let kind: AddressKind?

    /// Initialize an empty address for tests. This will fail in the actual
    /// service when it gets validated.
    public init() {
        name = ""
        line1 = ""
        line2 = ""
        city = ""
        country = ""
        code = ""
        kind = nil
    }

    /// Initialize an address with all of its fields.
    public init(name: String, line1: String, line2: String, city: String,
                country: String, code: String, kind: AddressKind? = nil)
    {
        self.name = name
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.country = country
        self.code = code
        self.kind = kind
    }

    /// Try some basic validations on the address.
    public func validate() throws {
        if name.isEmpty {
            throw AccountsError.invalidAddress(.invalidName)
        }

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

        guard let kind = kind else {
            return
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
        return name.hashValue ^ line1.hashValue ^ line2.hashValue
               ^ city.hashValue ^ country.hashValue ^ code.hashValue
    }

    public static func ==(lhs: Address, rhs: Address) -> Bool {
        return lhs.name == rhs.name &&
               lhs.line1 == rhs.line1 &&
               lhs.line2 == rhs.line2 &&
               lhs.city == rhs.city &&
               lhs.country == rhs.country &&
               lhs.code == rhs.code
    }
}
