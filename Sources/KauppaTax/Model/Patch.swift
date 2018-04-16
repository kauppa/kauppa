import Foundation

import KauppaCore

/// This has the mutable fields from `Country`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated.
public struct CountryPatch: Mappable {
    public var name: String? = nil
    public var taxRate: TaxRate? = nil
}

/// This has the mutable fields from `Region`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated.
public struct RegionPatch: Mappable {
    public var name: String? = nil
    public var taxRate: TaxRate? = nil
    public var kind: RegionKind? = nil
    public var countryId: UUID? = nil
}
