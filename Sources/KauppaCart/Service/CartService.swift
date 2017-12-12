import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaProductsClient
import KauppaCartClient
import KauppaCartModel
import KauppaCartRepository

/// Public API for the cart belonging to a customer account.
public class CartService {
    let repository: CartRepository
    let productsService: ProductsServiceCallable
    let accountsService: AccountsServiceCallable

    /// Initializes a new `CartService` instance with a
    /// repository, accounts and products service.
    public init(withRepository repository: CartRepository,
                productsService: ProductsServiceCallable,
                accountsService: AccountsServiceCallable)
    {
        self.repository = repository
        self.productsService = productsService
        self.accountsService = accountsService
    }
}

extension CartService: CartServiceCallable {
    public func addCartItem(forAccount userId: UUID, withUnit unit: CartUnit) throws -> Cart {
        if unit.quantity == 0 {
            throw CartError.noItemsToProcess
        }

        let _ = try accountsService.getAccount(id: userId)
        let product = try productsService.getProduct(id: unit.productId)
        // FIXME: Verify inventory

        // FIXME: Verify currency

        var items = try repository.getCartItems(forId: userId)
        items.append(unit)

        return try repository.updateCartItems(forId: userId, items: items)
    }
}
