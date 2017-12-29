import Foundation

import KauppaCore
@testable import KauppaCartModel
@testable import KauppaCartStore

public class TestStore: CartStorable {
    public var carts = [UUID: Cart]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false
    public var updateCalled = false

    public func createCart(with data: Cart) throws -> () {
        createCalled = true
        carts[data.id] = data
    }

    public func getCart(for id: UUID) throws -> Cart {
        getCalled = true
        guard let cart = carts[id] else {
            throw ServiceError.cartUnavailable
        }

        return cart
    }

    public func updateCart(with data: Cart) throws -> () {
        updateCalled = true
        carts[data.id] = data
    }
}
