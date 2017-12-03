import Foundation

import KauppaCore
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaProductsModel
import KauppaOrdersRepository
import KauppaProductsClient

/// Orders service
public class OrdersService: OrdersServiceCallable {
    let repository: OrdersRepository

    let productsService: ProductsServiceCallable

    public init(withRepository repository: OrdersRepository,
                productsService: ProductsServiceCallable)
    {
        self.repository = repository
        self.productsService = productsService
    }

    public func createOrder(data: OrderData) -> Order? {
        let weightCounter = WeightCounter()
        var order = Order()
        var inventoryUpdates = [(UUID, UInt32)]()

        if data.products.isEmpty {
            return nil
        }

        for orderUnit in data.products {
            guard let product = productsService.getProduct(id: orderUnit.id) else {
                return nil      // Invalid product ID
            }

            if orderUnit.quantity == 0 {
                continue    // skip zero'ed items
            }

            let available = product.data.inventory
            if available < orderUnit.quantity {
                return nil      // Not enough items in inventory
            }

            let leftover = available - UInt32(orderUnit.quantity)
            inventoryUpdates.append((product.id, leftover))

            let orderedUnit = OrderedProduct(id: product.id,
                                             processedItems: orderUnit.quantity)
            order.products.append(orderedUnit)

            order.totalPrice += Double(orderUnit.quantity) * product.data.price
            var weight = product.data.weight ?? UnitMeasurement(value: 0.0, unit: .gram)
            weight.value *= Double(orderUnit.quantity)
            weightCounter.add(weight)
            order.totalItems += UInt16(orderUnit.quantity)
        }

        for (id, leftover) in inventoryUpdates {
            var patch = ProductPatch()
            patch.inventory = leftover
            // FIXME: What if the client fails for some reason?
            let _ = productsService.updateProduct(id: id, data: patch)
        }

        order.totalWeight = weightCounter.sum()
        return repository.createOrder(withData: order)
    }
}
