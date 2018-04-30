import Foundation

import KauppaCore

/// An object representing an address.
public struct Address: Mappable, Hashable {
    /// First name of the person (associated with this address)
    public var firstName: String = ""
    /// Last name of the person (associated with this address)
    public var lastName: String? = nil
    /// Address line 1
    public var line1: String = ""
    /// Address line 2
    public var line2: String? = nil
    /// Province
    public var province: String = ""
    /// City
    public var city: String = ""
    /// Country
    public var country: String = ""
    /// Postal/ZIP code
    ///
    /// There's no general regex (unlike email).
    /// See the complications here - https://stackoverflow.com/a/7185241/
    public var code: String = ""
    /// Label for this address.
    public var label: String? = nil

    /// Initialize an empty address (for tests).
    public init() {}

    /// Initialize an address with all of its fields.
    public init(firstName: String, lastName: String?, line1: String, line2: String?, city: String,
                province: String, country: String, code: String, label: String? = nil)
    {
        self.firstName = firstName
        self.lastName = lastName
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.province = province
        self.country = country
        self.code = code
        self.label = label
    }

    /// Try some basic validations on the address. This checks if any of the fields
    /// in the address are empty.
    public func validate() throws {
        if firstName.isEmpty {
            throw ServiceError.invalidAddressName
        }

        // Last name is optional

        if line1.isEmpty {
            throw ServiceError.invalidAddressLineData
        }

        // Line 2 is optional

        if city.isEmpty {
            throw ServiceError.invalidAddressCity
        }

        if province.isEmpty {
            throw ServiceError.invalidAddressProvince
        }

        if country.isEmpty {
            throw ServiceError.invalidAddressCountry
        }

        if code.isEmpty {
            throw ServiceError.invalidAddressCode
        }

        if let label = label {
            if label.isEmpty {
                throw ServiceError.invalidAddressLabel
            }
        }
    }

    public var hashValue: Int {
        var hash = firstName.hashValue ^ line1.hashValue ^ city.hashValue
                   ^ province.hashValue ^ country.hashValue ^ code.hashValue
        if let name = lastName {
            hash ^= name.hashValue
        }

        if let line2 = line2 {
            hash ^= line2.hashValue
        }

        return hash
    }

    public static func ==(lhs: Address, rhs: Address) -> Bool {
        return lhs.firstName == rhs.firstName &&
               lhs.lastName == rhs.lastName &&
               lhs.line1 == rhs.line1 &&
               lhs.line2 == rhs.line2 &&
               lhs.city == rhs.city &&
               lhs.province == rhs.province &&
               lhs.country == rhs.country &&
               lhs.code == rhs.code
    }
}
