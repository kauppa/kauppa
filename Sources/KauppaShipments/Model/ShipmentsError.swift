import Foundation

/// Shipment service errors
public enum ShipmentsError: Error {
    case noItemsToProcess
    case invalidShipment
    case notScheduledForPickup
    case notQueuedForShipping
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
