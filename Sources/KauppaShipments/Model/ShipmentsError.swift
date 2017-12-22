import Foundation

/// Shipment service errors
public enum ShipmentsError: Error {
    case noItemsToProcess
}

extension ShipmentsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .noItemsToProcess:
                return "No items to process"
        }
    }
}

extension ShipmentsError {
    /// Check the equality of this result.
    public static func ==(lhs: ShipmentsError, rhs: ShipmentsError) -> Bool {
        switch (lhs, rhs) {
            case (.noItemsToProcess, .noItemsToProcess):
                return true
            // default:
            //     return false
        }
    }
}
