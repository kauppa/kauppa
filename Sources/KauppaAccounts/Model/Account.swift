import Foundation

import KauppaCore

/// Account structure that exists in repository and store.
public struct Account: Mappable {
    /// Unique identifier for this account.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// User-supplied data
    public var data: AccountData

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: AccountData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }

    /// A verified account has at least one verified email.
    public var isVerified: Bool {
        for email in data.emails {
            if email.isVerified {
                return true
            }
        }

        return false
    }
}
