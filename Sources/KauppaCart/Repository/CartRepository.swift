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

    /// Create a cart with data from the service.
    public func createCart(data: CartData) throws -> Cart {
        let id = UUID()
        let date = Date()
        let cart = Cart(id: id, createdOn: date,
                        updatedAt: date, data: data)
        carts[id] = cart
        try store.createCart(data: cart)
        return cart
    }
}
