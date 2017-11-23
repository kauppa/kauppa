import Foundation

class MemoryStore {
    var accounts = [UUID: Account]()
    var emailIds = [String: UUID]()
    var orders = [UUID: Order]()
    var products = [UUID: Product]()
}

extension MemoryStore: Store {
    func getAccountForEmail(email: String) -> Account? {
        if let id = self.emailIds[email] {
            return self.accounts[id]
        } else {
            return nil
        }
    }

    func createIdForEmail(email: String, id: UUID) {
        emailIds[email] = id
    }

    func createAccountWithId(id: UUID, account: Account) {
        accounts[id] = account
    }

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
