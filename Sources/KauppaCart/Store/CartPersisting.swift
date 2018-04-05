import Foundation

import KauppaCore
import KauppaCartModel

/// Methods that mutate the underlying store with information.
public protocol CartPersisting: Persisting {
    /// Create a cart with data from the repository.
    func createCart(with data: Cart) throws -> ()

    /// Update a cart with data from repository.
    func updateCart(with data: Cart) throws -> ()
}
