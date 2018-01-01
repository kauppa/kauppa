import Foundation

import KauppaCore
import KauppaCartModel
import KauppaCartStore

/// Manages the retrieval and persistance of cart data from store.
public class CartRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var carts = [UUID: Cart]()
    var store: CartStorable

    public init(withStore store: CartStorable) {
        self.store = store
    }

    /// Get the cart associated with a customer account.
    ///
    /// Since carts are always associated with a customer account,
    /// we make sure that a cart always exists for an account.
    ///
    /// Whenever the repository asks the store for a cart, the store
    /// can either return the cart, or respond that the cart doesn't
    /// exist, or fail with some other error.
    ///
    /// In case the store doesn't have a cart, the repository initializes
    /// one, and propagates any other error.
    public func getCart(forId id: UUID) throws -> Cart {
        guard let cart = carts[id] else {
            let cart: Cart
            do {
                cart = try store.getCart(id: id)
            } catch CartError.cartUnavailable {
                cart = Cart(withId: id)
                try store.createCart(data: cart)
            } catch let err {
                throw err
            }

            carts[id] = cart
            return cart
        }

        return cart
    }

    /// Update the items in a customer's cart.
    public func updateCart(data: Cart) throws -> Cart {
        var cart = data
        cart.updatedAt = Date()
        cart.items = data.items
        cart.currency = data.currency
        carts[cart.id] = cart
        try store.updateCart(data: cart)
        return cart
    }
}
