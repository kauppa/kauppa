import Foundation

import KauppaGiftsModel

public protocol GiftsServiceCallable {
    /// Create a gift card with the given data.
    func createCard(withData data: GiftCardData) throws -> GiftCard

    /// Update a gift card with the given patch.
    func updateCard(id: UUID, data: GiftCardPatch) throws -> GiftCard
}
