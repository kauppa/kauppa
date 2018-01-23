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
    public init(withRepository repository: CartRepository,
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
    public func addCartItem(forAccount userId: UUID, with unit: CartUnit) throws -> Cart {
        let account = try accountsService.getAccount(id: userId)
        let cart = try repository.getCart(forId: userId)
        let itemCreator = CartItemCreator(from: account, forCart: cart, with: unit)
        try itemCreator.updateCart(using: productsService)
        return try repository.updateCart(data: itemCreator.cart)
    }

    public func applyCoupon(forAccount userId: UUID, code: String) throws -> Cart {
        let _ = try accountsService.getAccount(id: userId)
        var cart = try repository.getCart(forId: userId)
        if cart.items.isEmpty {     // cannot apply coupon when there aren't any items.
            throw CartError.noItemsInCart
        }

        var coupon = try couponService.getCoupon(forCode: code)
        var zero = UnitMeasurement(value: 0.0, unit: cart.netPrice!.unit)
        // This only validates the coupon - because we're passing zero.
        try coupon.data.deductPrice(from: &zero)
        cart.coupons.insert(coupon.id)

        return try repository.updateCart(data: cart)
    }

    public func getCart(forAccount userId: UUID) throws -> Cart {
        let _ = try accountsService.getAccount(id: userId)
        // FIXME: Make sure that product items are available

        return try repository.getCart(forId: userId)
    }

    public func placeOrder(forAccount userId: UUID, data: CheckoutData) throws -> Order {
        let account = try accountsService.getAccount(id: userId)
        var cart = try repository.getCart(forId: userId)
        if cart.items.isEmpty {
            throw CartError.noItemsToProcess
        }

        guard let shippingAddress = account.data.address.get(from: data.shippingAddressAt) else {
            throw CartError.invalidAddress
        }

        var billingAddress: Address? = nil
        if let idx = data.billingAddressAt {
            guard let address = account.data.address.get(from: idx) else {
                throw CartError.invalidAddress
            }

            billingAddress = address
        }

        var units = [OrderUnit]()
        for unit in cart.items {
            units.append(OrderUnit(product: unit.product, quantity: unit.quantity))
        }

        var orderData = OrderData(shippingAddress: shippingAddress, billingAddress: billingAddress,
                                  placedBy: userId, products: units)
        orderData.appliedCoupons = cart.coupons
        let order = try ordersService.createOrder(data: orderData)

        cart.reset()
        let _ = try repository.updateCart(data: cart)
        return order
    }
}
