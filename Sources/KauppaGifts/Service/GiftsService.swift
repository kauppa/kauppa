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

// NOTE: See the actual protocol in `KauppaGiftsClient` for exact usage.
extension GiftsService: GiftsServiceCallable {
    public func createCard(withData data: GiftCardData) throws -> GiftCard {
        var cardData = data
        try cardData.validate()
        return try repository.createCard(data: cardData)
    }

    public func getCard(id: UUID) throws -> GiftCard {
        var card = try repository.getCard(forId: id)
        card.data.hideCode()
        return card
    }

    public func getCard(forCode code: String) throws -> GiftCard {
        var card = try repository.getCard(forCode: code)
        card.data.hideCode()
        return card
    }

    public func updateCard(id: UUID, data: GiftCardPatch) throws -> GiftCard {
        var cardData = try repository.getCardData(forId: id)

        if data.disable ?? false {
            cardData.disabledOn = Date()
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
