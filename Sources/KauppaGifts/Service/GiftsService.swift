import Foundation

import KauppaCore
import KauppaGiftsClient
import KauppaGiftsModel
import KauppaGiftsRepository

/// Public API for creation/modification of gift cards.
public class GiftsService {
    let repository: GiftsRepository

    /// Initializes a new `GiftsService` instance with a repository.
    public init(withRepository repository: GiftsRepository) {
        self.repository = repository
    }
}

extension GiftsService: GiftsServiceCallable {
    public func createCard(withData data: GiftCardData) throws -> GiftCard {
        var cardData = data
        try cardData.validate()
        return try repository.createCard(data: cardData)
    }

    public func updateCard(id: UUID, data: GiftCardPatch) throws -> GiftCard {
        var cardData = try repository.getCardData(forId: id)

        if let date = data.disabledOn {
            cardData.disabledOn = date
        }

        if let value = data.balance {
            cardData.balance = value
        }

        if let date = data.expiresOn {
            cardData.expiresOn = date
        }

        if let note = data.note {
            cardData.note = note
        }

        try cardData.validate()
        var card = try repository.updateCardData(id: id, data: cardData)
        card.data.hideCode()
        return card
    }
}
