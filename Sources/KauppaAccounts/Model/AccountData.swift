import Foundation

import KauppaCore

/// User-supplied data for an account.
public struct AccountData: Mappable {
    /// Name of the user
    public let name: String
    /// User's email
    public let email: String
    /// User's phone number
    public let phone: String
    /// A list of user's addresses
    public let address: [Address]

    public init() {
        self.name = ""
        self.email = ""
        self.phone = ""
        self.address = []
    }
}
