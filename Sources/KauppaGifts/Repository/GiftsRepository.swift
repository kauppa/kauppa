import Foundation

import KauppaCore
import KauppaGiftsModel
import KauppaGiftsStore

/// Manages the retrieval and persistance of gift card data from store.
public class GiftsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var cards = [UUID: GiftCard]()
    var store: GiftsStorable

    public init(withStore store: GiftsStorable) {
        self.store = store
    }

    /// Create a gift card with data from the service.
    public func createCard(data: GiftCardData) throws -> GiftCard {
        let card = GiftCard(withData: data)
        cards[card.id] = card
        try store.createCard(data: card)
        return card
    }

    /// Fetch the gift card from repository if available, or get it from store.
    public func getCard(forId id: UUID) throws -> GiftCard {
        guard let card = cards[id] else {
            let card = try store.getCard(id: id)
            cards[id] = card
            return card
        }

        return card
    }

    /// Get the user-supplied data for a gift card.
    public func getCardData(forId id: UUID) throws -> GiftCardData {
        let card = try getCard(forId: id)
        return card.data
    }

    /// Update a card with data from the service.
    public func updateCardData(id: UUID, data: GiftCardData) throws -> GiftCard {
        var card = try getCard(forId: id)
        card.updatedAt = Date()
        cards[id] = card
        card.data = data
        try store.updateCard(data: card)
        return card
    }
}
