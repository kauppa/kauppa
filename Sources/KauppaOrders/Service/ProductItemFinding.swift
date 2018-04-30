import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaProductsModel

extension OrdersService {
    /// Given a product ID and order data, this function finds the index
    /// of that product item in the order, and ensures that the order item
    /// has been fulfilled.
    ///
    /// - Parameters:
    ///   - in: The `Order` in which the fulfillment is verified.
    ///   - for: The product ID to be matched.
    ///   - expectFulfillment: Whether we're expecting fulfillment for that product.
    /// - Returns: Index of the found product (if it exists)
    /// - Throws: `ServiceError` if no products are found, or if the item
    /// hasn't been fulfilled.
    static func findEnumeratedProduct(in order: Order, for id: UUID,
                                      expectFulfillment: Bool = true) throws -> Int
    {
        for (idx, unit) in order.products.enumerated() {
            if id != unit.item.product {
                continue
            }

            // Make sure that only fulfilled (delivered) items are returned/refunded/picked up.
            if expectFulfillment && unit.status == nil {
                throw ServiceError.unfulfilledItem
            }

            return idx
        }

        throw ServiceError.invalidItemId    // no such item exists in order.
    }
}
