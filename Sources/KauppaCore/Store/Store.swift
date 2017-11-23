import Foundation

protocol Store {
    func getAccountForEmail(email: String) -> Account?

    func createNewProductWithId(id: UUID, product: Product)
    func getProductForId(id: UUID) -> Product?
    func removeProductIfExists(id: UUID) -> Product?
    func updateProductForId(id: UUID, product: Product)
    func removeFromInventory(id: UUID, quantity: UInt32)

    func createNewOrder(id: UUID, order: Order)
    func removeOrderIfExists(id: UUID) -> Order?
}
