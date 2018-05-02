import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaCartModel
import KauppaCouponClient
import KauppaProductsClient
import KauppaProductsModel
import KauppaTaxClient

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
    /// - Throws: `ServiceError`
    ///   - If the product doesn't exist.
    ///   - If there was an error in adding the product (low on inventory or invalid quantity).
    func addCartItem(using productsService: ProductsServiceCallable,
                     with unit: CartUnit) throws
    {
        if unit.quantity == 0 {
            throw ServiceError.noItemsToProcess
        }

        let product = try productsService.getProduct(for: unit.product, from: nil)
        if unit.quantity > product.inventory {
            throw ServiceError.productUnavailable      // precheck inventory
        }

        try checkPrice(for: product)
        let itemExists = try updateExistingItem(for: product, with: unit)
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
    /// - Throws: `ServiceError` if the item doesn't exist in the cart.
    func removeCartItem(using productsService: ProductsServiceCallable,
                        with itemId: UUID) throws
    {
        var itemIndex: Int? = nil
        for (i, item) in cart.items.enumerated() {
            if itemId == item.product {
                itemIndex = i
            }
        }

        if let idx = itemIndex {
            cart.items.remove(at: idx)
        } else {
            throw ServiceError.invalidItemId
        }
    }

    /// Apply coupon to this cart using the coupon service.
    ///
    /// - Parameters:
    ///   - with: The `CartCoupon` object which contains coupon data.
    ///   - using: Anything that implements `CouponServiceCallable`
    /// - Throws: `ServiceError` if the coupon doesn't exist or cannot be applied.
    func applyCoupon(with data: CartCoupon, using couponService: CouponServiceCallable) throws {
        if cart.items.isEmpty {     // cannot apply coupon when there aren't any items.
            throw ServiceError.noItemsInCart
        }

        var coupon = try couponService.getCoupon(for: data.code)
        var zero = UnitMeasurement(value: 0.0, unit: cart.netPrice!.unit)
        // This only validates the coupon - because we're passing zero.
        try coupon.data.deductPrice(from: &zero)

        if cart.coupons == nil {
            cart.coupons = ArraySet([coupon.id])
        } else {
            cart.coupons!.insert(coupon.id)
        }
    }

    /// Updates existing cart data with the given cart data. This resets the items and coupons
    /// in the existing cart, filters duplicates (for efficiency) and continuously calls
    /// `addCartItem` and `applyCoupon` to mutate the cart.
    ///
    /// - Parameters:
    ///   - with: The new `Cart` object.
    ///   - using: Anything that implements `ProductsServiceCallable`
    ///   - and: Anything that implements `CouponServiceCallable`
    /// - Throws: `ServiceError`
    ///   - If the product doesn't exist.
    ///   - If there was an error in adding the product (low on inventory or invalid quantity).
    func updateCart(with data: Cart, using productsService: ProductsServiceCallable,
                    and couponService: CouponServiceCallable) throws
    {
        var newItems = [CartUnit]()
        data.items.forEach { item in
            if let idx = newItems.index(where: { $0.product == item.product }) {
                newItems[idx].quantity += item.quantity
            } else {
                newItems.append(item)
            }
        }

        // If checkout data is provided, validate and set it - otherwise, reset it.
        if var checkoutData = data.checkoutData {
            try checkoutData.validate(using: account)
            cart.checkoutData = checkoutData
        } else {
            cart.checkoutData = nil
        }

        let existingItems = cart.items
        cart.items = []

        do {
            try newItems.forEach { item in
                try addCartItem(using: productsService, with: item)
            }
        } catch let err {
            // Reset cart items on error
            cart.items = existingItems
            throw err
        }

        cart.coupons = ArraySet()
        if let _ = data.coupons {
            // FIXME: Support updating coupons. Currently, the cart stores UUID of the coupons.
            // But, the user applies coupons with their secret codes.
        }

        if cart.coupons!.isEmpty {
            cart.coupons = nil
        }
    }

    /// Checks that the cart items exist in inventory. This resets the items, sets the tax categories,
    /// net prices (of individual items and cart itself), removes invalid products and changes
    /// quantities based on the data of individual items. This must be called before returning the
    /// cart data from service.
    ///
    /// - Parameters:
    ///   - using: Anything that implements `ProductsServiceCallable`
    /// - Returns: `true` if the cart items have been modified (i.e., whether it
    /// should be updated in the repository) and `false` if it's not.
    func checkItemsAndSetPrices(using productsService: ProductsServiceCallable) -> Bool {
        // Reset both the cart prices
        cart.netPrice = nil
        cart.grossPrice = nil

        var isModified = false
        // Check that the products still exist and have enough units in inventory.
        var checkedItems = [CartUnit]()

        cart.items.forEach { unit in
            // Reset individual unit prices by creating a new instance
            var unit = unit
            unit.resetInternalProperties()

            guard let product = try? productsService.getProduct(for: unit.product, from: nil) else {
                isModified = true
                return
            }

            // If the quantity is higher than what's available in the inventory, then clamp it.
            if unit.quantity > product.inventory {
                isModified = true
                unit.quantity = UInt8(product.inventory)
            }

            if unit.quantity == 0 {
                return
            }

            // Set product category (for calculating tax later)
            unit.setTax(using: product.taxCategory)

            let netPrice = Double(unit.quantity) * product.price.value
            unit.netPrice = UnitMeasurement(value: netPrice, unit: product.price.unit)

            if cart.netPrice == nil {
                cart.netPrice = UnitMeasurement(value: 0, unit: product.price.unit)
            }

            cart.netPrice!.value += unit.netPrice!.value
            // Since we've added items using `addCartItem` which already checks for duplicates,
            // we can assume that all items in cart are unique.
            checkedItems.append(unit)
        }

        cart.items = checkedItems
        return isModified
    }

    /// Function to make sure that the cart maintains its currency unit.
    private func checkPrice(for product: Product) throws {
        if let price = cart.netPrice {
            if price.unit != product.price.unit {
                throw ServiceError.ambiguousCurrencies
            }
        } else {    // initialize price if it's not been done already
            cart.netPrice = UnitMeasurement(value: 0.0, unit: product.price.unit)
        }
    }

    /// Check if the product already exists (if it does, mutate the corresponding unit)
    private func updateExistingItem(for product: Product, with unit: CartUnit) throws -> Bool {
        var itemExists = false
        for (i, item) in cart.items.enumerated() {
            if item.product != product.id {
                continue
            }

            itemExists = true
            cart.items[i].quantity += unit.quantity

            // This is just for notifying the customer. Orders service
            // will verify this before placing the order anyway.
            if cart.items[i].quantity > product.inventory {
                throw ServiceError.productUnavailable
            }

            break
        }

        return itemExists
    }
}
