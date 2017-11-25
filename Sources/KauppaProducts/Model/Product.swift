import Foundation

public struct Product: Encodable {
    public let id: UUID
    public let createdOn: Date
    public var updatedAt: Date
    public var data: ProductData
    
    public init(id: UUID, createdOn: Date, updatedAt: Date, data: ProductData) {
        self.id = id
        self.createdOn = createdOn
        self.updatedAt = updatedAt
        self.data = data
    }
}
