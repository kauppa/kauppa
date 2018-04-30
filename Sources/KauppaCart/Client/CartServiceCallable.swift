import Foundation

import KauppaAccountsModel
import KauppaCartModel
import KauppaOrdersModel

/// General API for the cart service to be implemented by both the
/// service and the client.
public protocol CartServiceCallable {
    /// Add a product item to the cart associated with an account.
    ///
    /// Every account is associated with a cart which may or may not be empty.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account maintaining this cart.
    ///   - with: The `CartUnit` that needs to be added to the cart.
    ///   - from: The (optional) `Address` from which this request was originated.
    /// - Returns: The `Cart` data (with all the items contained inside).
    /// - Throws: `ServiceError`
    ///   - If the account doesn't exist.
    ///   - If the item couldn't be added to the cart.
    func addCartItem(for userId: UUID, with unit: CartUnit, from address: Address?) throws -> Cart

    /// Remove a product item from the cart associated with an account.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account maintaining this cart.
    ///   - with: The `UUID` of the product to be removed from the cart.
    ///   - from: The (optional) `Address` from which this request was originated.
    /// - Returns: The `Cart` data (with all the items contained inside).
    /// - Throws: `ServiceError`
    ///   - If the account doesn't exist.
    ///   - If the item is not found in the cart.
    func removeCartItem(for userId: UUID, with itemId: UUID, from address: Address?) throws -> Cart

    /// Update the cart with the given list of items. This replaces all items from the existing
    /// cart with the new IDs and quantities.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account maintaining this cart.
    ///   - with: The list of `CartUnit` objects.
    ///   - from: The (optional) `Address` from which this request was originated.
    /// - Returns: Updated `Cart` data (with all the items contained inside).
    /// - Throws: `ServiceError`
    ///   - If the account doesn't exist.
    ///   - If the item couldn't be added to the cart.
    func updateCart(for userId: UUID, with items: [CartUnit], from address: Address?) throws -> Cart

    /// Apply a coupon to this cart.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account maintaining this cart.
    ///   - using: The unique alphanumeric code of the coupon.
    ///   - from: The (optional) `Address` from which this request was originated.
    /// - Returns: The `Cart` with the coupon applied.
    /// - Throws: `ServiceError`
    ///   - If the account doesn't exist (or)
    ///   - If the given coupon code is invalid.
    func applyCoupon(for userId: UUID, using data: CartCoupon, from address: Address?) throws -> Cart

    /// Get the cart data for an account.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account maintaining this cart.
    ///   - from: The (optional) `Address` from which this request was originated.
    /// - Returns: The `Cart` data (with all the items contained inside)
    /// - Throws: `ServiceError` (if the account doesn't exist).
    func getCart(for userId: UUID, from address: Address?) throws -> Cart

    /// Checkout the cart and place an order with the items in the cart.
    ///
    /// On successful placement of the order, the items in the cart will be cleared.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account maintaining this cart.
    ///   - with: The `CheckoutData` required for placing an order.
    /// - Returns: An `Order` containing the items in the cart.
    /// - Throws: `ServiceError`
    ///   - If the account doesn't exist.
    ///   - If the cart doesn't have items or if the data is invalid.
    ///   - If the order couldn't be placed.
    func placeOrder(for userId: UUID, with data: CheckoutData) throws -> Order
}
