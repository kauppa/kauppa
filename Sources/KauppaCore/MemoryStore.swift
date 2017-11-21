import Foundation

class MemoryStore: ProductStore {
    var products = [UUID: Product]()
}
