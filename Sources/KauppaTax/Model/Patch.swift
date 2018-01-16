import KauppaCore

/// This has the mutable fields from `Country`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated.
public struct CountryPatch: Mappable {
    public var name: String? = nil
    public var taxRate: TaxRate? = nil

    public init() {}
}
