import Foundation

import KauppaCore

/// Struct with some of the fields from `GiftCardData` - all are optional.
/// This is used to change one or more fields of `GiftCardData` in a single
/// update request.
public struct GiftCardPatch: Mappable {
    public var disabledOn: Date? = nil
    public var balance: UnitMeasurement<Currency>? = nil
    public var expiresOn: Date? = nil
    public var note: String? = nil

    public init() {}
}
