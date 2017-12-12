import Foundation

@testable import KauppaCartModel
@testable import KauppaCartStore

public class TestStore: CartStorable {
    public var carts = [UUID: Cart]()

    // Variables to indicate the count of function calls
    public var createCalled = false

    public func createCart(data: Cart) throws -> () {
        createCalled = true
        carts[data.id] = data
        return ()
    }
}
