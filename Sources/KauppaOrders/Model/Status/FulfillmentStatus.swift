import KauppaCore

/// Status of an order. This is usually changed by the shipping service.
public enum FulfillmentStatus: String, Mappable {
    /// Order has been fulfilled (i.e., sent to customer).
    case fulfilled = "fulfilled"
    /// At least one item in this order has been sent.
    case partial = "partially fulfilled"
}
