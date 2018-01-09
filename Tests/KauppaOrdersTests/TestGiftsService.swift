import Foundation
import XCTest

import KauppaGiftsClient
import KauppaGiftsModel

public typealias GiftsCallback = (GiftCardPatch) -> Void

public class TestGiftsService: GiftsServiceCallable {
    var cards = [UUID: GiftCard]()
    var callbacks = [UUID: GiftsCallback]()

    public func createCard(withData data: GiftCardData) throws -> GiftCard {
        let card = GiftCard(withData: data)
        cards[card.id] = card
        return card
    }

    public func getCard(id: UUID) throws -> GiftCard {
        guard let card = cards[id] else {
            throw GiftsError.invalidGiftCardId
        }

        return card
    }

    // NOTE: Not meant to be called by orders
    public func getCard(forCode code: String) throws -> GiftCard {
        throw GiftsError.invalidGiftCardCode
    }

    public func updateCard(id: UUID, data: GiftCardPatch) throws -> GiftCard {
        if let callback = callbacks[id] {
            callback(data)
        }

        return try getCard(id: id)      // This is just a stub
    }
}
