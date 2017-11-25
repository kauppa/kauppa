import Foundation

import KauppaCore

public struct Address: Mappable {
    public let line1: String
    public let line2: String
    public let city: String
    public let country: String
    public let code: UInt32
    public let kind: AddressKind
}