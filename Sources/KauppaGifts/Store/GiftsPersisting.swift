import Foundation

import KauppaCore
import KauppaGiftsModel

/// Methods that mutate the underlying store with information.
public protocol GiftsPersisting: Persisting {
    /// Create a card with data from the repository.
    func createCard(data: GiftCard) throws -> ()

    /// Update a card with data from the repository.
    func updateCard(data: GiftCard) throws -> ()
}
