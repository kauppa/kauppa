import KauppaOrdersClient
import KauppaCore
import KauppaOrdersModel
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

        for orderUnit in data.products {
            guard var product = productsService.getProduct(id: orderUnit.id) else {
                // Invalid product ID
                return nil
            }

            if orderUnit.quantity == 0 {
                continue    // skip zero'ed items
            }

            let available = product.data.inventory
            if available < orderUnit.quantity {
                // Not enough items in inventory
                return nil
            }

            // FIXME: Update product inventory
            let orderedUnit = OrderedProduct(id: product.id,
                                             processedItems: orderUnit.quantity)
            order.products.append(orderedUnit)

            order.totalPrice += Double(orderUnit.quantity) * product.data.price
            var weight = product.data.weight ?? UnitMeasurement(value: 0.0, unit: .gram)
            weight.value *= Double(orderUnit.quantity)
            weightCounter.add(weight)
            order.totalItems += UInt16(orderUnit.quantity)
        }

        order.totalWeight = weightCounter.sum()
        return repository.createOrder(withData: order)
    }
}
