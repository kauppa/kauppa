import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsClient
import KauppaCouponClient
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaProductsClient
import KauppaTaxClient
import KauppaCartClient
import KauppaCartModel
import KauppaCartRepository

/// Public API for the cart belonging to a customer account.
public class CartService {
    let repository: CartRepository
    let productsService: ProductsServiceCallable
    let accountsService: AccountsServiceCallable
    let ordersService: OrdersServiceCallable
    let couponService: CouponServiceCallable
    let taxService: TaxServiceCallable

    /// Initializes a new `CartService` instance with a repository,
    /// accounts, products, coupon, orders and tax service.
    ///
    /// - Parameters:
    ///   - with: `CartRepository`
    ///   - productsService: Anything that implements `ProductsServiceCallable`
    ///   - accountsService: Anything that implements `AccountsServiceCallable`
    ///   - couponService: Anything that implements `CouponServiceCallable`
    ///   - ordersService: Anything that implements `OrdersServiceCallable`
    ///   - taxService: Anything that implements `TaxServiceCallable`
    public init(with repository: CartRepository,
                productsService: ProductsServiceCallable,
                accountsService: AccountsServiceCallable,
                couponService: CouponServiceCallable,
                ordersService: OrdersServiceCallable,
                taxService: TaxServiceCallable)
    {
        self.repository = repository
        self.productsService = productsService
        self.accountsService = accountsService
        self.ordersService = ordersService
        self.couponService = couponService
        self.taxService = taxService
    }
}

// NOTE: See the actual protocol in `KauppaCartClient` for exact usage.
extension CartService: CartServiceCallable {
    public func addCartItem(for userId: UUID, with unit: CartUnit,
                            from address: Address?) throws -> Cart
    {
        let account = try accountsService.getAccount(for: userId)
        let cart = try repository.getCart(for: userId)
        let modifier = CartItemModifier(for: cart, from: account)
        try modifier.addCartItem(using: productsService, with: unit)
        try repository.updateCart(with: modifier.cart)
        return try getCart(for: userId, from: address)
    }

    public func removeCartItem(for userId: UUID, with itemId: UUID,
                               from address: Address?) throws -> Cart
    {
        let account = try accountsService.getAccount(for: userId)
        let cart = try repository.getCart(for: userId)
        let modifier = CartItemModifier(for: cart, from: account)
        try modifier.removeCartItem(using: productsService, with: itemId)
        try repository.updateCart(with: modifier.cart)
        return try getCart(for: userId, from: address)
    }

    public func updateCart(for userId: UUID, with data: Cart,
                           from address: Address?) throws -> Cart
    {
        let account = try accountsService.getAccount(for: userId)
        let cart = try repository.getCart(for: userId)
        let modifier = CartItemModifier(for: cart, from: account)
        try modifier.updateCart(with: data, using: productsService, and: couponService)
        try repository.updateCart(with: modifier.cart)
        return try getCart(for: userId, from: address)
    }

    public func applyCoupon(for userId: UUID, using data: CartCoupon,
                            from address: Address?) throws -> Cart
    {
        let account = try accountsService.getAccount(for: userId)
        let cart = try repository.getCart(for: userId)
        let modifier = CartItemModifier(for: cart, from: account)
        try modifier.applyCoupon(with: data, using: couponService)
        try repository.updateCart(with: modifier.cart)
        return try getCart(for: userId, from: address)
    }

    public func getCart(for userId: UUID, from address: Address?) throws -> Cart {
        let account = try accountsService.getAccount(for: userId)
        var cart = try repository.getCart(for: userId)
        let modifier = CartItemModifier(for: cart, from: account)
        let isModified = modifier.checkItemsAndSetPrices(using: productsService)

        cart = modifier.cart    // new cart has all the price data

        // Update the repository only if the items/quantities change. Prices change all the time.
        if isModified {
            try repository.updateCart(with: cart)
        }

        // Cart (by itself) doesn't store tax information. It gets the tax data
        // from the tax service, applies those rates to the cart items and
        // returns the mutated data upon request.
        if let address = address {
            if !cart.items.isEmpty {
                let taxRate = try taxService.getTaxRate(for: address)
                cart.setPrices(using: taxRate)
            }
        }

        return cart
    }

    public func placeOrder(for userId: UUID, with data: CheckoutData) throws -> Order {
        let account = try accountsService.getAccount(for: userId)
        var checkoutData = data
        try checkoutData.validate(using: account)

        var cart = try repository.getCart(for: userId)
        if cart.items.isEmpty {
            throw ServiceError.noItemsToProcess
        }

        var units = [OrderUnit]()
        for unit in cart.items {
            units.append(OrderUnit(for: unit.product, with: unit.quantity))
        }

        var orderData = OrderData(shippingAddress: checkoutData.shippingAddress!,
                                  billingAddress: checkoutData.billingAddress ?? checkoutData.shippingAddress!,
                                  placedBy: userId, products: units)

        if let coupons = cart.coupons {
            orderData.appliedCoupons = coupons
        }

        let order = try ordersService.createOrder(with: orderData)

        cart.reset()
        try repository.updateCart(with: cart)

        return order
    }
}
