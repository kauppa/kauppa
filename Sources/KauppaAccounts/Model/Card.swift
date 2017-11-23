import Foundation

import KauppaCore

public struct Card {
    public let number: String      // Card number shouldn't be shown later, right?
    public let expiryMonth: Month
    public let expiryYear: UInt16
    public let firstName: String
    public let lastName: String
    public let cardType: CardType
}