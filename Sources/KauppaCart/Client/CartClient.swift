import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaOrdersModel

/// HTTP client for the cart service.
public class CartServiceClient<C: ClientCallable>: ServiceClient<C, CartRoutes>, CartServiceCallable {
    public func addCartItem(for userId: UUID, with unit: OrderUnit, from address: Address?) throws -> Cart {
        let client = try createClient(for: .addItemToCart, with: ["id": userId])
        try client.setJSON(using: unit)
        return try requestJSON(with: client)
    }

    public func removeCartItem(for userId: UUID, with itemId: UUID, from address: Address?) throws -> Cart {
        let client = try createClient(for: .removeItemFromCart, with: ["id": userId, "item": itemId])
        return try requestJSON(with: client)
    }

    public func updateCart(for userId: UUID, with data: Cart, from address: Address?) throws -> Cart {
        let client = try createClient(for: .updateCart, with: ["id": userId])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func applyCoupon(for userId: UUID, using data: CartCoupon, from address: Address?) throws -> Cart {
        let client = try createClient(for: .applyCoupon, with: ["id": userId])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func getCart(for userId: UUID, from address: Address?) throws -> Cart {
        let client = try createClient(for: .getCart, with: ["id": userId])
        return try requestJSON(with: client)
    }

    public func createCheckout(for userId: UUID, with data: CheckoutData) throws -> Cart {
        let client = try createClient(for: .createCheckout, with: ["id": userId])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func placeOrder(for userId: UUID) throws -> Order {
        let client = try createClient(for: .placeOrder, with: ["id": userId])
        return try requestJSON(with: client)
    }
}
