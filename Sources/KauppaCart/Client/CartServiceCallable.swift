import Foundation

import KauppaCartModel

/// General API for the cart service to be implemented by both the
/// service and the client.
public protocol CartServiceCallable {
    /// Add product item(s) to an account's cart.
    func addCartItem(forAccount userId: UUID, withUnit unit: CartUnit) throws -> Cart

    /// Get the cart data for an account.
    func getCart(forAccount userId: UUID) throws -> Cart
}
