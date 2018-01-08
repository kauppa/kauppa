import Foundation

import KauppaCore

/// Struct with some of the fields from `GiftCardData` - all are optional.
/// This is used to change one or more fields of `GiftCardData` in a single
/// update request.
public struct GiftCardPatch: Mappable {
    /// Disable the gift card.
    public var disable: Bool? = nil
    /// New balance for the gift card.
    public var balance: UnitMeasurement<Currency>? = nil
    /// Set the expiry date for the gift card.
    public var expiresOn: Date? = nil
    /// Add a note for the gift card.
    public var note: String? = nil

    public init() {}
}
