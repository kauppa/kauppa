import Foundation

import KauppaCore

/// Account structure that exists in repository and store.
public struct Account: Mappable {
    /// Unique identifier for this account.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public let updatedAt: Date
    /// User-supplied data
    public let data: AccountData

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: AccountData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }
}
