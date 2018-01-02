import Foundation

import KauppaGiftsModel

public protocol GiftsServiceCallable {
    /// Create a gift card with the given data.
    func createCard(withData data: GiftCardData) throws -> GiftCard

    /// Get the card for the given alphanumeric code (if any).
    func getCard(forCode code: String) throws -> GiftCard

    /// Update a gift card with the given patch.
    func updateCard(id: UUID, data: GiftCardPatch) throws -> GiftCard
}
