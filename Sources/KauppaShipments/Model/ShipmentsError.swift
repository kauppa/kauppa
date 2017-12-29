import Foundation

/// Shipment service errors
public enum ShipmentsError: Error {
    case noItemsToProcess
    case invalidShipment
}

extension ShipmentsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .noItemsToProcess:
                return "No items to process"
            case .invalidShipment:
                return "Invalid shipment for the given ID"
        }
    }
}

extension ShipmentsError: Equatable {
    /// Check the equality of this result.
    public static func ==(lhs: ShipmentsError, rhs: ShipmentsError) -> Bool {
        switch (lhs, rhs) {
            case (.noItemsToProcess, .noItemsToProcess),
                 (.invalidShipment, .invalidShipment):
                return true
            default:
                return false
        }
    }
}
