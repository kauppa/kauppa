import Foundation

@testable import KauppaGiftsModel
@testable import KauppaGiftsStore

public class TestStore: GiftsStorable {
    public var cards = [UUID: GiftCard]()

    // Variables to indicate the count of function calls.
    public var createCalled = false
    public var getCalled = false
    public var updateCalled = false

    public func createCard(data: GiftCard) throws -> () {
        createCalled = true
        cards[data.id] = data
        return ()
    }

    public func getCard(id: UUID) throws -> GiftCard {
        getCalled = true
        guard let card = cards[id] else {
            throw GiftsError.invalidGiftCardId
        }

        return card
    }

    public func updateCard(data: GiftCard) throws -> () {
        updateCalled = true
        cards[data.id] = data
        return ()
    }
}
