import Foundation

public struct AccountData {
    public let name: String
    public let email: String
    public let phone: String
    public let address: [Address]
    public let cards: [Card]

    public init() {
        self.name = ""
        self.email = ""
        self.phone = ""
        self.address = []
        self.cards = []
    }
}