import Foundation

public struct Product: Encodable {
    /// Unique identifier for this product.
    public let id: UUID
    /// Creation timestamp
    public let createdOn: Date
    /// Last updated timestamp
    public var updatedAt: Date
    /// Product's data supplied by the user.
    public var data: ProductData

    public init(id: UUID, createdOn: Date, updatedAt: Date, data: ProductData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }
}
