import Foundation

import KauppaOrdersModel
import KauppaProductsModel

extension OrdersService {
    /// Given a product ID and order data, this function finds the index
    /// of that product item in the order, gets the product data from the products
    /// service (if any), and ensures that the order item has been fulfilled.
    static func findEnumeratedProduct(inOrder order: Order, forId id: UUID,
                                      expectFulfillment: Bool = true) throws -> Int
    {
        for (idx, unit) in order.products.enumerated() {
            if id != unit.item.product {
                continue
            }

            // Make sure that only fulfilled (delivered) items are returned/refunded/picked up.
            if expectFulfillment && unit.status == nil {
                throw OrdersError.unfulfilledItem(id)
            }

            return idx
        }

        throw OrdersError.invalidOrderItem      // no such item exists in order.
    }
}
