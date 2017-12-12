import Foundation

import KauppaCore

/// This has most of the fields from `AccountData`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated for an account.
public struct AccountPatch: Mappable {
    public var name: String? = nil
    // FIXME: Multiple things to worry when we're changing email
    // (verification mail and check that account doesn't exist already)
    // public var email: String? = nil
    public var phone: String? = nil
    public var address: ArraySet<Address>? = nil

    public init() {}
}

/// This adds individual items to the collections residing in `AccountData`
public struct AccountPropertyAdditionPatch: Mappable {
    public var address: Address? = nil

    public init() {}
}

/// This has the nullable items from `AccountData` - any delete
/// request having one or more of these fields set to `true`
/// will reset that field in `AccountData`
public struct AccountPropertyDeletionPatch: Mappable {
    public var removePhone: Bool? = nil
    public var removeAddressAt: Int? = nil

    public init() {}
}
