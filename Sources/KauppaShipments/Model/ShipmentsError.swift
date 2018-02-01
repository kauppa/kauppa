import Foundation

/// Shipment service errors
public enum ShipmentsError: Error {
    /// No items to process from the given data (i.e., empty list of items).
    case noItemsToProcess
    /// No shipment found for the given UUID
    case invalidShipment
        /// This action requires the shipment to be in 'pickup' state, but it's not.
    case notScheduledForPickup
    /// This action requires the shipment to be in 'shipping' state, but it's not.
    case notQueuedForShipping
    /// This action requires the shipment to be in 'shipped' state, but it's not.
    case notBeingShipped
}

extension ShipmentsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .noItemsToProcess:
                return "No items to process"
            case .invalidShipment:
                return "Invalid shipment for the given ID"
            case .notScheduledForPickup:
                return "Shipment hasn't been scheduled for pickup"
            case .notQueuedForShipping:
                return "This shipment is not queued for shipping"
            case .notBeingShipped:
                return "This shipment hasn't been shipped"
        }
    }
}

extension ShipmentsError: Equatable {
    /// Check the equality of this result.
    public static func ==(lhs: ShipmentsError, rhs: ShipmentsError) -> Bool {
        switch (lhs, rhs) {
            case (.noItemsToProcess, .noItemsToProcess),
                 (.invalidShipment, .invalidShipment),
                 (.notScheduledForPickup, .notScheduledForPickup),
                 (.notQueuedForShipping, .notQueuedForShipping),
                 (.notBeingShipped, .notBeingShipped):
                return true
            default:
                return false
        }
    }
}
