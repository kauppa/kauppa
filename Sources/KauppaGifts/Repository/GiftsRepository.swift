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
        let id = UUID()
        let date = Date()
        let card = GiftCard(id: id, createdOn: date,
                            updatedAt: date, data: data)
        cards[id] = card
        try store.createCard(data: card)
        return card
    }
}
