import Foundation

import KauppaGiftsModel

public protocol GiftsServiceCallable {
    /// Create a gift card with the given data.
    func createCard(withData data: GiftCardData) throws -> GiftCard
}
