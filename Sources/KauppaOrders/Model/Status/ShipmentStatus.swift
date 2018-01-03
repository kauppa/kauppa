import KauppaCore

/// Status of the shipment for an order.
public enum ShipmentStatus: String, Mappable {
    /// Items have been queued for shipping.
    case shipping = "shipping"
    /// Some (or all) items have been shipped
    case shipped = "shipped"
    /// Some (or all) items have been delivered
    case delivered = "delivered"
    /// Some (or all) items have been scheduled for pickup
    case pickup = "pickup"
    /// Some (or all) items have been returned
    case returned = "returned"

    /// Check the equality of this type.
    public static func ==(lhs: ShipmentStatus, rhs: ShipmentStatus) -> Bool {
        switch (lhs, rhs) {
            case (.shipped, .shipped),
                 (.shipping, .shipping),
                 (.delivered, .delivered),
                 (.pickup, .pickup),
                 (.returned, .returned):
                return true
            default:
                return false
        }
    }
}
