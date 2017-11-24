import Foundation

import KauppaCore

public struct AccountData: Mappable {
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

extension AccountData: Encodable {
    public func encode(to encoder: Encoder) throws {

    }
}

extension AccountData: Decodable {
    public init(from decoder: Decoder) throws {
        self.name = ""
        self.email = ""
        self.phone = ""
        self.address = []
        self.cards = []
    }
}