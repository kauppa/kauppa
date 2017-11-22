import Foundation

class MemoryStore {
    var orders = [UUID: Order]()
    var products = [UUID: Product]()
}
