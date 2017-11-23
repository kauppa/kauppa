import Foundation

protocol OrderStore {
    func createOrder(order: OrderData) -> Order?
    func cancelOrder(id: UUID) -> Order?
}

extension MemoryStore: OrderStore {
    func createOrder(order: OrderData) -> Order? {
        let id = UUID()
        let date = Date()
        let weightCounter = WeightCounter()
        var totalPrice = 0.0
        var totalItems: UInt16 = 0
        var productList = [OrderedProduct]()

        for orderUnit in order.products {
            if let product = self.getProductForId(id: orderUnit.id) {
                let available = product.data.inventory
                let quantity = available > orderUnit.quantity ? UInt32(orderUnit.quantity) : available
                self.removeFromInventory(id: orderUnit.id, quantity: quantity)
                totalPrice += Double(quantity) * product.data.price
                var weight = product.data.weight ?? UnitMeasurement(value: 0.0, unit: .gram)
                weight.value *= Double(quantity)
                weightCounter.add(weight)
                totalItems += UInt16(quantity)
                productList.append(OrderedProduct(data: product,
                                                  productExists: true,
                                                  processedItems: UInt8(quantity)))
            } else {
                productList.append(OrderedProduct(data: nil,
                                                  productExists: false,
                                                  processedItems: 0))
            }
        }

        if totalItems > 0 {
            let order = Order(id: id, createdOn: date, updatedAt: date,
                              products: productList, totalItems: totalItems,
                              totalPrice: totalPrice, totalWeight: weightCounter.sum())
            self.createNewOrder(id: id, order: order)
            return order
        } else {
            return nil
        }
    }

    func cancelOrder(id: UUID) -> Order? {
        return self.removeOrderIfExists(id: id)
    }
}
