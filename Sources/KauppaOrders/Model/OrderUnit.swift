import Foundation

public struct OrderUnit: Codable {
    /// Product ID
    public let id: UUID
    /// Quantity of this product required
    public let quantity: UInt8
}
