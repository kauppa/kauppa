import Foundation
import XCTest

import KauppaGiftsClient
import KauppaGiftsModel

public class TestGiftsService: GiftsServiceCallable {
    var cards = [UUID: GiftCard]()

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

    public func getCard(forCode code: String) throws -> GiftCard {
        for (_, card) in cards {
            if card.data.code == code {
                return card
            }
        }

        throw GiftsError.invalidGiftCardCode
    }

    // NOTE: Not meant to be called by cart
    public func updateCard(id: UUID, data: GiftCardPatch) throws -> GiftCard {
        throw GiftsError.invalidGiftCardId
    }
}
