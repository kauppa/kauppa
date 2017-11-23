import Foundation 

public enum AddressKind: String, Codable {
    case home  = "home"
    case work  = "work"
    // FIXME: Should support custom labels
}