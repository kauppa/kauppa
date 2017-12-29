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
        let itemCreator = CartItemCreator(from: account, for: cart, with: unit)
        try itemCreator.updateCartData(using: productsService, with: address)
        try repository.updateCart(with: itemCreator.cart)
        return try getCart(for: userId, from: address)
    }

    public func applyCoupon(for userId: UUID, using code: String,
                            from address: Address?) throws -> Cart
    {
        let _ = try accountsService.getAccount(for: userId)
        var cart = try repository.getCart(for: userId)
        if cart.items.isEmpty {     // cannot apply coupon when there aren't any items.
            throw ServiceError.noItemsInCart
        }

        var coupon = try couponService.getCoupon(for: code)
        var zero = UnitMeasurement(value: 0.0, unit: cart.netPrice!.unit)
        // This only validates the coupon - because we're passing zero.
        try coupon.data.deductPrice(from: &zero)
        cart.coupons.insert(coupon.id)

        try repository.updateCart(with: cart)
        return try getCart(for: userId, from: address)
    }

    public func getCart(for userId: UUID, from address: Address?) throws -> Cart {
        let _ = try accountsService.getAccount(for: userId)
        // FIXME: Make sure that product items are available

        // Cart (by itself) doesn't store tax information. It gets the tax data
        // from the tax service, applies those rates to the cart items and
        // returns the mutated data upon request.
        var cart = try repository.getCart(for: userId)
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
        var cart = try repository.getCart(for: userId)
        if cart.items.isEmpty {
            throw ServiceError.noItemsToProcess
        }

        guard let shippingAddress = account.data.address.get(from: data.shippingAddressAt) else {
            throw ServiceError.invalidAddress
        }

        var billingAddress: Address? = nil
        if let idx = data.billingAddressAt {
            guard let address = account.data.address.get(from: idx) else {
                throw ServiceError.invalidAddress
            }

            billingAddress = address
        }

        var units = [OrderUnit]()
        for unit in cart.items {
            units.append(OrderUnit(for: unit.product, with: unit.quantity))
        }

        var orderData = OrderData(shippingAddress: shippingAddress, billingAddress: billingAddress,
                                  placedBy: userId, products: units)
        orderData.appliedCoupons = cart.coupons
        let order = try ordersService.createOrder(with: orderData)

        cart.reset()
        try repository.updateCart(with: cart)
        return order
    }
}
