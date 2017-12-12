import Foundation

import KauppaCartModel

public protocol CartServiceCallable {
    /// Create a cart with the given product data.
    func createCart(withData data: CartData) throws -> Cart
}
