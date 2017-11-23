import Foundation

public enum CardType: String, Codable {
    case visa       = "visa"
    case masterCard = "mastercard"
    // ...
}

public enum AddressKind: String, Codable {
    case home  = "home"
    case work  = "work"
    // FIXME: Should support custom labels
}

public struct Address: Codable {
    let line1: String
    let line2: String
    let city: String
    let country: String
    let code: UInt32
    let kind: AddressKind
}

public struct Card: Codable {
    let number: String      // Card number shouldn't be shown later, right?
    let expiryMonth: Month
    let expiryYear: UInt16
    let firstName: String
    let lastName: String
    let cardType: CardType
}

public struct AccountData: Codable {
    let name: String
    let email: String
    let phone: String
    let address: [Address]
    let cards: [Card]
}

public struct Account: Encodable {
    let id: UUID
    let createdOn: Date
    let updatedAt: Date
    let data: AccountData
}
