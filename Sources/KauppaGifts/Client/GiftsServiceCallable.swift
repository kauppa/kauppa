import Foundation

import KauppaGiftsModel

public protocol GiftsServiceCallable {
    /// Create a gift card with the given data.
    ///
    /// - Parameters:
    ///   - withData: `GiftCardData` required for creating a gift card.
    /// - Returns: A `GiftCard` with a valid alphanumeric code.
    /// - Throws: `GiftsError`
    func createCard(withData data: GiftCardData) throws -> GiftCard

    /// Get the card corresponding to an ID.
    ///
    /// - Parameters:
    ///   - id: `UUID` of this gift card.
    /// - Returns: The `GiftCard` (if it exists)
    /// - Throws: `GiftsError` (if it's non-existent)
    func getCard(id: UUID) throws -> GiftCard

    /// Get the card for the given alphanumeric code (if any).
    ///
    /// - Parameters:
    ///   - forCode: The unique alphanumeric code of a gift card.
    /// - Returns: The `GiftCard` (if it exists)
    /// - Throws: `GiftsError` (if it's non-existent)
    func getCard(forCode code: String) throws -> GiftCard

    /// Update a gift card with the given patch.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the gift card. **This is not the card's code!**
    ///   - data: The `GiftCardPatch` data for updating the corresponding gift card.
    /// - Returns: The `GiftCard` (if it's been successfully updated)
    /// - Throws: `GiftsError`
    func updateCard(id: UUID, data: GiftCardPatch) throws -> GiftCard
}
