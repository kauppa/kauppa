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

    /// Initialize an instance of `CartRepository` with a cart store.
    ///
    /// - Parameters:
    ///   - with: Anything that implements `CartStorable`
    public init(with store: CartStorable) {
        self.store = store
    }

    /// Get the cart associated with a customer account.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the cart.
    /// - Returns: The `Cart` for the given ID.
    /// - Throws: `ServiceError` if there was an error.
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
    public func getCart(for id: UUID) throws -> Cart {
        guard let cart = carts[id] else {
            let cart: Cart
            do {
                cart = try store.getCart(for: id)
            } catch ServiceError.cartUnavailable {
                cart = Cart(with: id)
                try store.createCart(with: cart)
            } catch let err {
                throw err
            }

            carts[id] = cart
            return cart
        }

        return cart
    }

    /// Update the items in a customer's cart.
    ///
    /// - Parameters:
    ///   - with: The updated `Cart` object.
    /// - Throws: `ServiceError` if there was an error updating the cart.
    public func updateCart(with data: Cart) throws -> () {
        var cart = data
        cart.updatedAt = Date()
        carts[cart.id] = cart
        try store.updateCart(with: cart)
    }
}
