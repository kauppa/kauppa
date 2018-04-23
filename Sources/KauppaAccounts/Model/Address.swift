import Foundation

import KauppaCore

/// An object representing an address.
public struct Address: Mappable, Hashable {
    /// Name of the person (associated with this address)
    public let name: String
    /// Address line 1
    public let line1: String
    /// Address line 2
    public let line2: String
    /// Province
    public var province: String
    /// City
    public var city: String
    /// Country
    public var country: String
    /// Postal/ZIP code
    ///
    /// There's no general regex (unlike email).
    /// See the complications here - https://stackoverflow.com/a/7185241/
    public let code: String
    /// Label for this address.
    public let label: String?

    /// Initialize an empty address (for tests).
    public init() {
        name = ""
        line1 = ""
        line2 = ""
        city = ""
        province = ""
        country = ""
        code = ""
        label = nil
    }

    /// Initialize an address with all of its fields.
    public init(name: String, line1: String, line2: String, city: String,
                province: String, country: String, code: String, label: String? = nil)
    {
        self.name = name
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
        if name.isEmpty {
            throw ServiceError.invalidAddressName
        }

        if line1.isEmpty {
            throw ServiceError.invalidAddressLineData
        }

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
