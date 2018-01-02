import Foundation

import KauppaCore
import KauppaGiftsModel

/// Methods that fetch data from the underlying store.
public protocol GiftsQuerying: Querying {
    /// Get a card associated with the given ID from store.
    func getCard(id: UUID) throws -> GiftCard

    /// Get a card associated with the given alphanumeric code.
    func getCard(code: String) throws -> GiftCard
}
