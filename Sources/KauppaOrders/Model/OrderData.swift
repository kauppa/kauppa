/// Input data for placing an order
public struct OrderData: Codable {
    /// List of product IDs and their quantity (as an order unit).
    public let products: [OrderUnit]
}
