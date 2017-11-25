import Foundation

import KauppaCore

public struct Account: Mappable {
    public let id: UUID
    public let createdOn: Date
    public let updatedAt: Date
    public let data: AccountData

    public init(id: UUID, createdOn: Date) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = createdOn
        self.data = AccountData()
    }

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: AccountData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }
}
