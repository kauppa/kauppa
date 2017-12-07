import Foundation

import KauppaCore

/// This has most of the fields from `AccountData`, but everything's optional.
/// It's used for an update request, where one or more of these properties
/// could be updated for an account.
public struct AccountPatch: Mappable {
    public var name: String? = nil
    public var email: String? = nil
    public var phone: String? = nil
    public var address: Set<Address>? = nil

    public init() {}
}
