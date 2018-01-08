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
        for (idx, orderUnit) in order.products.enumerated() {
            if id != orderUnit.product {
                continue
            }

            // Make sure that only fulfilled (delivered) items are returned/refunded/picked up.
            if expectFulfillment && orderUnit.status == nil {
                throw OrdersError.unfulfilledItem(id)
            }

            return idx
        }

        throw OrdersError.invalidOrderItem      // no such item exists in order.
    }

    /// Returns a list of all items that can be picked up from this order. This actually
    /// changes the `pickupQuantity` in each order unit (to indicate that the items have
    /// been scheduled for pickup).
    func getAllItemsForPickup(forOrder data: inout Order) throws -> [OrderUnit] {
        var returnItems = [OrderUnit]()
        for (i, unit) in data.products.enumerated() {
            let product = try productsService.getProduct(id: unit.product)
            // Only collect "untouched" items (if any) from each unit
            // (i.e., items that have been fulfilled and not scheduled for pickup)
            let fulfilled = unit.untouchedItems()
            if fulfilled > 0 {
                let returnUnit = OrderUnit(product: product.id, quantity: fulfilled)
                returnItems.append(returnUnit)
                data.products[i].status!.pickupQuantity += returnUnit.quantity
            }
        }

        return returnItems
    }
}
