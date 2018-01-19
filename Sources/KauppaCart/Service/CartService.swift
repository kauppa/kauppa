import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsClient
import KauppaCouponClient
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaProductsClient
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

    /// Initializes a new `CartService` instance with a
    /// repository, accounts, products and coupon service.
    public init(withRepository repository: CartRepository,
                productsService: ProductsServiceCallable,
                accountsService: AccountsServiceCallable,
                couponService: CouponServiceCallable,
                ordersService: OrdersServiceCallable)
    {
        self.repository = repository
        self.productsService = productsService
        self.accountsService = accountsService
        self.ordersService = ordersService
        self.couponService = couponService
    }
}

// NOTE: See the actual protocol in `KauppaCartClient` for exact usage.
extension CartService: CartServiceCallable {
    public func addCartItem(forAccount userId: UUID, withUnit unit: CartUnit) throws -> Cart {
        var unit = unit
        if unit.quantity == 0 {
            throw CartError.noItemsToProcess
        }

        let _ = try accountsService.getAccount(id: userId)
        let product = try productsService.getProduct(id: unit.productId)
        if unit.quantity > product.data.inventory {
            throw CartError.productUnavailable      // precheck inventory
        }

        let netPrice = Double(unit.quantity) * product.data.price.value
        unit.netPrice = UnitMeasurement(value: netPrice, unit: product.data.price.unit)

        var itemExists = false
        var cart = try repository.getCart(forId: userId)
        // Make sure that the cart maintains its currency unit
        if let price = cart.netPrice {
            if price.unit != product.data.price.unit {
                throw CartError.ambiguousCurrencies
            }
        } else {    // initialize price if it's not been done already
            cart.netPrice = UnitMeasurement(value: 0.0, unit: product.data.price.unit)
        }

        // Check if the product already exists (if it does, mutate the corresponding unit)
        for (i, item) in cart.items.enumerated() {
            if item.productId == product.id {
                itemExists = true
                cart.items[i].quantity += unit.quantity
                let netPrice = Double(cart.items[i].quantity) * product.data.price.value
                cart.items[i].netPrice!.value = netPrice

                // This is just for notifying the customer. Orders service
                // will verify this before placing the order.
                if cart.items[i].quantity > product.data.inventory {
                    throw CartError.productUnavailable
                }
            }
        }

        cart.netPrice!.value += unit.netPrice!.value
        if !itemExists {
            cart.items.append(unit)
        }

        return try repository.updateCart(data: cart)
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
            units.append(OrderUnit(product: unit.productId,
                                   quantity: unit.quantity))
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
