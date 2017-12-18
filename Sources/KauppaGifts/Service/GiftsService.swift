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
        return try repository.createCard(data: data)
    }
}
