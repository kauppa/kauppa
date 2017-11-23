import Foundation

class MemoryStore {
    var orders = [UUID: Order]()
    var products = [UUID: Product]()
}

extension MemoryStore: Store {
    func createNewProductWithId(id: UUID, product: Product) {
        products[id] = product
    }

    func getProductForId(id: UUID) -> Product? {
        return products[id]
    }

    func removeProductIfExists(id: UUID) -> Product? {
        if let product = products[id] {
            products.removeValue(forKey: id)
            return product
        } else {
            return nil
        }
    }

    func removeFromInventory(id: UUID, quantity: UInt32) {
        self.products[id]!.data.inventory -= quantity
    }

    func updateProductForId(id: UUID, product: Product) {
        products[id] = product
    }

    func createNewOrder(id: UUID, order: Order) {
        orders[id] = order
    }

    func removeOrderIfExists(id: UUID) -> Order? {
        if let order = orders[id] {
            orders.removeValue(forKey: id)
            return order
        } else {
            return nil
        }
    }
}
