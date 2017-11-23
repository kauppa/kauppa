import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaProductsModel

public class OrderStore {

    func createOrder(order: OrderData) -> Order? {
        let id = UUID()
        let date = Date()
        let weightCounter = WeightCounter()
        var totalPrice = 0.0
        var totalItems: UInt16 = 0
        var productList = [OrderedProduct]()

        for orderUnit in order.products {
            //TODO: if let product = self.getProductForId(id: orderUnit.id) {
                let product = Product(id: UUID(), createdOn: Date(), updatedAt: Date(), data: ProductData(title: "", subtitle: "", description: ""))
                let available = product.data.inventory
                let quantity = available > orderUnit.quantity ? UInt32(orderUnit.quantity) : available
                //TODO: self.removeFromInventory(id: orderUnit.id, quantity: quantity)
                totalPrice += Double(quantity) * product.data.price
                var weight = product.data.weight ?? UnitMeasurement(value: 0.0, unit: .gram)
                weight.value *= Double(quantity)
                weightCounter.add(weight)
                totalItems += UInt16(quantity)
                productList.append(OrderedProduct(data: product,
                                                  productExists: true,
                                                  processedItems: UInt8(quantity)))
            //} else {
                productList.append(OrderedProduct(data: nil,
                                                  productExists: false,
                                                  processedItems: 0))
            //}
        }

        if totalItems > 0 {
            let order = Order(id: id, createdOn: date, updatedAt: date,
                              products: productList, totalItems: totalItems,
                              totalPrice: totalPrice, totalWeight: weightCounter.sum())
            //TODO: self.createNewOrder(id: id, order: order)
            return order
        } else {
            return nil
        }
    }

    func cancelOrder(id: UUID) -> Order? {
        return nil
        //return self.removeOrderIfExists(id: id)
    }
}
