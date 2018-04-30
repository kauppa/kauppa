import Foundation

import KauppaCore
import KauppaCartModel

/// A no-op store for cart which doesn't support data persistence/querying.
/// This way, the repository takes care of all service requests by providing
/// in-memory data.
public class CartNoOpStore: CartStorable {
    public init() {}

    public func createCart(with data: Cart) throws -> () {}

    public func getCart(for id: UUID) throws -> Cart {
        throw ServiceError.cartUnavailable
    }

    public func updateCart(with data: Cart) throws -> () {}
}
