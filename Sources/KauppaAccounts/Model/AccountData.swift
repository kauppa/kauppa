import Foundation

import KauppaCore

/// User-supplied data for an account.
public struct AccountData: Mappable {
    /// Name of the user
    public var name: String = ""
    /// User's email
    public var email: String = ""
    /// User's phone number
    public var phone: String? = nil
    /// A list of user's addresses
    public var address = ArraySet<Address>()

    public init() {}
}
