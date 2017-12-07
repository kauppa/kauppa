import Foundation

import KauppaCore

/// User-supplied data for an account.
public struct AccountData: Mappable {
    /// Name of the user
    public var name: String
    /// User's email
    public var email: String
    /// User's phone number
    public var phone: String
    /// A list of user's addresses
    public var address: Set<Address>

    public init() {
        self.name = ""
        self.email = ""
        self.phone = ""
        self.address = []
    }
}
