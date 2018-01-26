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
    ///   - forAccount: The `UUID` of the account maintaining this cart.
    /// - Returns: The `Cart` data (with all the items contained inside)
    /// - Throws:
    ///   - `AccountsError` if the account doesn't exist.
    ///   - `CartError` if the item couldn't be added to the cart.
    func addCartItem(forAccount userId: UUID, with unit: CartUnit,
                     from address: Address) throws -> Cart

    /// Apply a coupon to this cart.
    ///
    /// - Parameters:
    ///   - forAccount: The `UUID` of the account maintaining this cart.
    ///   - code: The unique alphanumeric code of the coupon.
    /// - Returns: The `Cart` with the coupon applied.
    /// - Throws:
    ///   - `AccountsError` if the account doesn't exist.
    ///   - `CouponError` if the given coupon code is invalid.
    func applyCoupon(forAccount userId: UUID, code: String,
                     from address: Address) throws -> Cart

    /// Get the cart data for an account.
    ///
    /// - Parameters:
    ///   - forAccount: The `UUID` of the account maintaining this cart.
    /// - Returns: The `Cart` data (with all the items contained inside)
    /// - Throws: `AccountsError` (if the account doesn't exist)
    func getCart(forAccount userId: UUID, from address: Address) throws -> Cart

    /// Checkout the cart and place an order with the items in the cart.
    ///
    /// On successful placement of the order, the items in the cart will be cleared.
    ///
    /// - Parameters:
    ///   - forAccount: The `UUID` of the account maintaining this cart.
    ///   - data: The `CheckoutData` required for placing an order.
    /// - Returns: An `Order` containing the items in the cart.
    /// - Throws:
    ///   - `AccountsError` if the account doesn't exist
    ///   - `CartError` if the cart doesn't have items or if the data is invalid.
    ///   - `OrdersError` if the order couldn't be placed.
    func placeOrder(forAccount userId: UUID, data: CheckoutData) throws -> Order
}
