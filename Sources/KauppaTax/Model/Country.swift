import Foundation

import KauppaCore

/// Input country data.
public struct CountryData: Mappable {
    /// Name of the country.
    public let name: String
    /// Tax rate for this country.
    public let taxRate: TaxRate

    /// Initialize this data with name and tax rate.
    ///
    /// - Parameters:
    ///   - name: Name of the country.
    ///   - taxRate: `TaxRate` data for this country.
    public init(name: String, taxRate: TaxRate) {
        self.name = name
        self.taxRate = taxRate
    }
}

/// Country object created by the service (used by repository and store).
public struct Country: Mappable {
    /// Unique ID for this country
    public let id = UUID()
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Name of this country (unique)
    public var name: String
    /// Tax rates used in this country.
    public var taxRate: TaxRate

    /// Initailize this object with a name and tax rate. Creation and last updated
    /// timestamps will be equal.
    ///
    /// - Parameters:
    ///   - name: Name of the country.
    ///   - taxRate: `TaxRate` data for this country.
    public init(name: String, taxRate: TaxRate) {
        let date = Date()
        createdOn = date
        updatedAt = date
        self.name = name
        self.taxRate = taxRate
    }
}
