import Foundation
import KauppaCore

import KauppaCore

/// Label for an address.
public enum AddressKind: Mappable, Equatable {
    case home
    case work
    case custom(String)

    public func encode(to encoder: Encoder) throws {
        let string: String
        switch self {
            case .home:
                string = "home"
            case .work:
                string = "work"
            case .custom(let value):
                string = value
        }

        try string.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        let string = try String(from: decoder)
        switch string {
            case "home":
                self = .home
            case "work":
                self = .work
            default:
                self = .custom(string)
        }
    }

    public static func ==(lhs: AddressKind, rhs: AddressKind) -> Bool {
        switch (lhs, rhs) {
            case (.home, .home),
                 (.work, .work):
                return true
            case let (.custom(s1), .custom(s2)):
                return s1 == s2
            default:
                return false
        }
    }
}
