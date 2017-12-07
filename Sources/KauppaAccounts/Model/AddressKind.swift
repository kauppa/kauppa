import Foundation

import KauppaCore

/// Label for an address.
public enum AddressKind: String, Mappable {
    case home  = "home"
    case work  = "work"
    // FIXME: Should support custom labels
}
