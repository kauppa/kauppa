import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaProductsModel

/// An order unit which has the entire product data.
public typealias DetailedUnit = GenericOrderUnit<Product>

/// Order that has the entire product data.
public typealias DetailedOrder = GenericOrder<Account, DetailedUnit>

// NOTE: This is a workaround because (at the time of this implementation)
// Swift didn't allow us to implement protocol extensions for constrained types.
public struct MailOrder {
    public let inner: DetailedOrder

    public init(from order: DetailedOrder) {
        inner = order
    }
}

extension MailOrder: MailFormattable {
    public func createMailSubject() -> String {
        return "Your order has been placed"
    }

    // FIXME: This is just a stub - needs beautification
    public func createMailDescription() -> String {
        return """
Order ID: \(inner.id)
"""
    }
}
