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
    public func createCart(withData data: CartData) throws -> Cart {
        return try repository.createCart(data: data)
    }
}
