import Foundation

import KauppaCore

/// Review structure that exists in repository and store.
public struct Review: Mappable {
    /// Unique identifier for this review.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// User-supplied data
    public var data: ReviewData

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: ReviewData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }
}
