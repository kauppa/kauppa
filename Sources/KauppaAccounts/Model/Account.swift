import Foundation

import KauppaCore

/// Account structure that exists in repository and store.
public struct Account: Mappable {
    /// Unique identifier for this account.
    public var id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// User-supplied data
    public var data: AccountData

    /// Initialize this `Account` with account data. This sets the ID to a random UUID
    /// and creation and updated timestamps to "now".
    ///
    /// - Parameters:
    ///   - with: The `AccountData` for this account
    public init(with data: AccountData) {
        let date = Date()
        self.id = UUID()
        self.createdOn = date
        self.updatedAt = date
        self.data = data
    }

    /// Checks whether a verified account has at least one verified email.
    public var isVerified: Bool {
        return data.emails.get(matching: { $0.isVerified }) != nil
    }
}
