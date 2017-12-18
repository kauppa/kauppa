import Foundation

@testable import KauppaGiftsModel
@testable import KauppaGiftsStore

public class TestStore: GiftsStorable {
    public var cards = [UUID: GiftCard]()

    // Variables to indicate the count of function calls.
    public var createCalled = false

    public func createCard(data: GiftCard) throws -> () {
        createCalled = true
        cards[data.id] = data
        return ()
    }
}
