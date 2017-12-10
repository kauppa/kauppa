import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaProductsClient
import KauppaProductsModel

/// Service that manages orders placed by customers.
public class OrdersService: OrdersServiceCallable {
    let repository: OrdersRepository
    let accountsService: AccountsServiceCallable
    let productsService: ProductsServiceCallable

    /// Initialize this service with its repository, along with
    /// instances of clients to account and product services.
    public init(withRepository repository: OrdersRepository,
                accountsService: AccountsServiceCallable,
                productsService: ProductsServiceCallable)
    {
        self.repository = repository
        self.accountsService = accountsService
        self.productsService = productsService
    }

    public func createOrder(data: OrderData) throws -> Order {
        let weightCounter = WeightCounter()
        var order = Order()
        var inventoryUpdates = [UUID: UInt32]()

        let _ = try accountsService.getAccount(id: data.placedBy)
        order.placedBy = data.placedBy

        for orderUnit in data.products {
            let product = try productsService.getProduct(id: orderUnit.id)
            if orderUnit.quantity == 0 {
                continue    // skip zero'ed items
            }

            // Also check for duplicate product
            let available = inventoryUpdates[product.id] ?? product.data.inventory
            if available < orderUnit.quantity {
                throw OrdersError.productUnavailable
            }

            let leftover = available - UInt32(orderUnit.quantity)
            inventoryUpdates[product.id] = leftover

            let orderedUnit = OrderedProduct(id: product.id,
                                             processedItems: orderUnit.quantity)
            order.products.append(orderedUnit)

            order.totalPrice += Double(orderUnit.quantity) * product.data.price
            var weight = product.data.weight ?? UnitMeasurement(value: 0.0, unit: .gram)
            weight.value *= Double(orderUnit.quantity)
            weightCounter.add(weight)
            order.totalItems += UInt16(orderUnit.quantity)
        }

        if inventoryUpdates.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        for (id, leftover) in inventoryUpdates {
            var patch = ProductPatch()
            patch.inventory = leftover
            // FIXME: What if the client fails for some reason?
            let _ = try? productsService.updateProduct(id: id, data: patch)
        }

        order.totalWeight = weightCounter.sum()
        return try repository.createOrder(withData: order)
    }

    public func deleteOrder(id: UUID) throws -> () {
        return try repository.deleteOrder(id: id)
    }
}
