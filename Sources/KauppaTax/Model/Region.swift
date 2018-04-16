import Foundation

import KauppaCore

/// All regions have country as their parent, but a region
/// could be one of these types.
public enum RegionKind: String, Mappable {
    case city = "city"
    case province = "province"
    case district = "district"
}

/// Input region data.
public struct RegionData: Mappable {
    /// Name of the region.
    public let name: String
    /// Tax rate for this region.
    public let taxRate: TaxRate
    /// Type of this region.
    public let kind: RegionKind

    /// Initialize this instance with region name, kind and tax rate.
    ///
    /// - Parameters:
    ///   - name: Name of this region.
    ///   - taxRate: `TaxRate` data for this region.
    ///   - kind: The type of this region.
    public init(name: String, taxRate: TaxRate, kind: RegionKind) {
        self.name = name
        self.taxRate = taxRate
        self.kind = kind
    }
}

/// Region object created by the service (used by repository and store)
public struct Region: Mappable {
    /// Unique ID for this region
    public let id = UUID()
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Name of this region
    public var name: String
    /// Tax rates used in this region.
    public var taxRate: TaxRate
    /// Parent country for this region.
    public var countryId: UUID
    /// Type of this region.
    public var kind: RegionKind

    /// Initializes this object with a name, tax rate and parent country's ID.
    /// Creation and last updated timestamps will be equal.
    ///
    /// - Parameters:
    ///   - name: Name of this region.
    ///   - taxRate: `TaxRate` data for this region.
    ///   - kind: The type of this region.
    ///   - country: The `UUID` of the country to which this region belongs to.
    public init(name: String, taxRate: TaxRate, kind: RegionKind, country: UUID) {
        countryId = country
        let date = Date()
        createdOn = date
        updatedAt = date
        self.name = name
        self.taxRate = taxRate
        self.kind = kind
    }
}
