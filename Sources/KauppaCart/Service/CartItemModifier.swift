import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaProductsClient
import KauppaProductsModel

/// Factory class for adding a new item to the cart. This gets the item from the products
/// service and updates the quantity of the item in the cart.
class CartItemModifier {
    /// Actual cart data which is used by this class. It's set during initialization,
    /// and the service gets it after performing necessary checks and updating it.
    public private(set) var cart: Cart

    private let account: Account

    /// Initialize this factory with the account, cart and the added cart unit.
    ///
    /// - Parameters:
    ///   - for: The `Cart` belonging to that account.
    ///   - from: The `Account` which requested to add the cart item.
    init(for cart: Cart, from account: Account) {
        self.account = account
        self.cart = cart
    }

    /// Update this cart by adding the initialized cart unit.
    ///
    /// - Parameters:
    ///   - using: Anything that implements `ProductsServiceCallable`
    ///   - with: The `CartUnit` added by the account.
    ///   - from: (Optional) `Address` of the account.
    /// - Throws: `ServiceError`
    ///   - If the product doesn't exist.
    ///   - If there was an error in adding the product.
    func addCartItem(using productsService: ProductsServiceCallable,
                     with unit: CartUnit, from address: Address?) throws
    {
        var unit = unit
        unit.resetInternalProperties()
        if unit.quantity == 0 {
            throw ServiceError.noItemsToProcess
        }

        let product = try productsService.getProduct(for: unit.product, from: address)
        // set product category (for calculating tax later)
        unit.setTax(using: product.data.taxCategory)

        if unit.quantity > product.data.inventory {
            throw ServiceError.productUnavailable      // precheck inventory
        }

        let netPrice = Double(unit.quantity) * product.data.price.value
        unit.netPrice = UnitMeasurement(value: netPrice, unit: product.data.price.unit)
        try checkPrice(for: product)
        let itemExists = try updateExistingItem(for: product, with: unit)

        cart.netPrice!.value += unit.netPrice!.value
        if !itemExists {
            cart.items.append(unit)
        }
    }

    /// Removes an item from the cart (if it exists), and updates the net price
    /// of the cart.
    ///
    /// - Parameters:
    ///   - using: Anything that implements `ProductsServiceCallable`
    ///   - with: The `UUID` of the item to be removed.
    ///   - from: (Optional) `Address` of the account.
    /// - Throws: `ServiceError` if the item doesn't exist in the cart.
    func removeCartItem(using productsService: ProductsServiceCallable,
                        with itemId: UUID, from address: Address?) throws
    {
        var itemIndex: Int? = nil
        for (i, item) in cart.items.enumerated() {
            if itemId == item.product {
                itemIndex = i
            }
        }

        if let idx = itemIndex {
            let unit = cart.items.remove(at: idx)
            cart.netPrice!.value -= unit.netPrice!.value
        } else {
            throw ServiceError.invalidItemId
        }
    }

    /// Function to make sure that the cart maintains its currency unit.
    private func checkPrice(for product: Product) throws {
        if let price = cart.netPrice {
            if price.unit != product.data.price.unit {
                throw ServiceError.ambiguousCurrencies
            }
        } else {    // initialize price if it's not been done already
            cart.netPrice = UnitMeasurement(value: 0.0, unit: product.data.price.unit)
        }
    }

    /// Check if the product already exists (if it does, mutate the corresponding unit)
    private func updateExistingItem(for product: Product, with unit: CartUnit) throws -> Bool {
        var itemExists = false
        for (i, item) in cart.items.enumerated() {
            if item.product == product.id {
                itemExists = true
                cart.items[i].quantity += unit.quantity
                let netPrice = Double(cart.items[i].quantity) * product.data.price.value
                cart.items[i].netPrice!.value = netPrice

                // This is just for notifying the customer. Orders service
                // will verify this before placing the order anyway.
                if cart.items[i].quantity > product.data.inventory {
                    throw ServiceError.productUnavailable
                }
            }
        }

        return itemExists
    }
}
