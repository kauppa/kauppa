import KauppaCore

/// Input data for placing an order
public struct OrderData: Mappable {
    /// List of product IDs and their quantity (as an order unit).
    public let products: [OrderUnit]
}
