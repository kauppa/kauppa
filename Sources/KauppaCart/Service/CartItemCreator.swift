import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaProductsClient
import KauppaProductsModel

/// Factory class for adding a new item to the cart. This gets the item from the products
/// service and updates the quantity of the item in the cart.
class CartItemCreator {
    /// Actual cart data which is used by this class. It's set during initialization,
    /// and the service gets it after performing necessary checks and updating it.
    public private(set) var cart: Cart

    private let account: Account
    private var unit: CartUnit
    private var itemExists = false

    /// Initialize this factory with the account, cart and the added cart unit.
    ///
    /// - Parameters:
    ///   - from: The `Account` which requested to add the cart item.
    ///   - for: The `Cart` belonging to that account.
    ///   - with: The `CartUnit` that's been added by the account.
    init(from account: Account, for cart: Cart, with unit: CartUnit) {
        self.account = account
        self.cart = cart
        self.unit = unit
        self.unit.resetInternalProperties()
    }

    /// Update this cart with the initiailized cart unit.
    ///
    /// - Parameters:
    ///   - using: Anything that implements `ProductsServiceCallable`
    ///   - with: (Optional) `Address` of the account.
    /// - Throws: `ServiceError`
    ///   - If the product doesn't exist.
    ///   - If there was an error in adding the product.
    func updateCartData(using productsService: ProductsServiceCallable,
                        with address: Address?) throws
    {
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
        try updateItemIfExists(for: product)

        cart.netPrice!.value += unit.netPrice!.value
        if !itemExists {
            cart.items.append(unit)
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
    private func updateItemIfExists(for product: Product) throws {
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
    }
}
