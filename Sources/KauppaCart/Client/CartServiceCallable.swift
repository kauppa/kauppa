import Foundation

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
    func addCartItem(forAccount userId: UUID, withUnit unit: CartUnit) throws -> Cart

    /// Apply a gift card to this cart.
    ///
    /// - Parameters:
    ///   - forAccount: The `UUID` of the account maintaining this cart.
    ///   - code: The unique alphanumeric code of the gift card.
    /// - Returns: The `Cart` with the gift card applied.
    /// - Throws:
    ///   - `AccountsError` if the account doesn't exist.
    ///   - `GiftsError` if the given card is invalid.
    func applyGiftCard(forAccount userId: UUID, code: String) throws -> Cart

    /// Get the cart data for an account.
    ///
    /// - Parameters:
    ///   - forAccount: The `UUID` of the account maintaining this cart.
    /// - Returns: The `Cart` data (with all the items contained inside)
    /// - Throws: `AccountsError` (if the account doesn't exist)
    func getCart(forAccount userId: UUID) throws -> Cart

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
