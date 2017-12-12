import Foundation

import KauppaCartModel

public protocol CartServiceCallable {
    /// Add product item(s) to an account's cart.
    func addCartItem(forAccount userId: UUID, withUnit unit: CartUnit) throws -> Cart
}
