import Foundation

import KauppaCore
import KauppaCartModel

/// Methods that mutate the underlying store with information.
public protocol CartPersisting: Persisting {
    /// Create a cart with data from the repository.
    ///
    /// - Parameters:
    ///   - with: The `Cart` data from the repository.
    /// - Throws: `ServiceError` on failure.
    func createCart(with data: Cart) throws -> ()

    /// Update a cart with data from repository.
    ///
    /// - Parameters:
    ///   - with: Updated `Cart` data from repository.
    /// - Throws: `ServiceError` on failure.
    func updateCart(with data: Cart) throws -> ()
}
