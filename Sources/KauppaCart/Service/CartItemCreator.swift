import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaProductsClient
import KauppaProductsModel

/// Factory class for adding a new item to the cart.
class CartItemCreator {
    private let account: Account
    private var unit: CartUnit
    /// Actual cart data which is used by this class. It's set during initialization,
    /// and the service gets it after performing necessary checks and updating it.
    public private(set) var cart: Cart

    private var itemExists = false

    init(from account: Account, forCart cart: Cart, with unit: CartUnit) {
        self.account = account
        self.cart = cart
        self.unit = unit
        self.unit.resetInternalProperties()
    }

    // Function to make sure that the cart maintains its currency unit.
    func checkPrice(forProduct product: Product) throws {
        if let price = cart.netPrice {
            if price.unit != product.data.price.unit {
                throw CartError.ambiguousCurrencies
            }
        } else {    // initialize price if it's not been done already
            cart.netPrice = UnitMeasurement(value: 0.0, unit: product.data.price.unit)
        }
    }

    /// Check if the product already exists (if it does, mutate the corresponding unit)
    func updateItemIfExists(forProduct product: Product) throws {
        for (i, item) in cart.items.enumerated() {
            if item.product == product.id {
                itemExists = true
                cart.items[i].quantity += unit.quantity
                let netPrice = Double(cart.items[i].quantity) * product.data.price.value
                cart.items[i].netPrice!.value = netPrice

                // This is just for notifying the customer. Orders service
                // will verify this before placing the order anyway.
                if cart.items[i].quantity > product.data.inventory {
                    throw CartError.productUnavailable
                }
            }
        }
    }

    /// Update this cart with the supplied cart unit.
    func updateCartData(using productsService: ProductsServiceCallable) throws {
        if unit.quantity == 0 {
            throw CartError.noItemsToProcess
        }

        let product = try productsService.getProduct(id: unit.product)
        // set product category (for calculating tax later)
        unit.tax.category = product.data.category
        if unit.quantity > product.data.inventory {
            throw CartError.productUnavailable      // precheck inventory
        }

        let netPrice = Double(unit.quantity) * product.data.price.value
        unit.netPrice = UnitMeasurement(value: netPrice, unit: product.data.price.unit)
        try checkPrice(forProduct: product)
        try updateItemIfExists(forProduct: product)

        cart.netPrice!.value += unit.netPrice!.value
        if !itemExists {
            cart.items.append(unit)
        }
    }
}
