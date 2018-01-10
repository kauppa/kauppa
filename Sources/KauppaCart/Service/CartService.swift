import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsClient
import KauppaGiftsClient
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
    let giftsService: GiftsServiceCallable

    /// Initializes a new `CartService` instance with a
    /// repository, accounts and products service.
    public init(withRepository repository: CartRepository,
                productsService: ProductsServiceCallable,
                accountsService: AccountsServiceCallable,
                giftsService: GiftsServiceCallable,
                ordersService: OrdersServiceCallable)
    {
        self.repository = repository
        self.productsService = productsService
        self.accountsService = accountsService
        self.ordersService = ordersService
        self.giftsService = giftsService
    }
}

// NOTE: See the actual protocol in `KauppaCartClient` for exact usage.
extension CartService: CartServiceCallable {
    public func addCartItem(forAccount userId: UUID, withUnit unit: CartUnit) throws -> Cart {
        if unit.quantity == 0 {
            throw CartError.noItemsToProcess
        }

        let _ = try accountsService.getAccount(id: userId)
        let product = try productsService.getProduct(id: unit.productId)
        if unit.quantity > product.data.inventory {
            throw CartError.productUnavailable      // precheck inventory
        }

        var itemExists = false
        var cart = try repository.getCart(forId: userId)
        // Make sure that the cart maintains its currency unit
        if let currency = cart.currency {
            if currency != product.data.price.unit {
                throw CartError.ambiguousCurrencies
            }
        } else {
            cart.currency = product.data.price.unit
        }

        // Check if the product already exists
        for (i, item) in cart.items.enumerated() {
            if item.productId == product.id {
                itemExists = true
                cart.items[i].quantity += unit.quantity

                // This is just for notifying the customer. Orders service
                // will verify this before placing the order.
                if cart.items[i].quantity > product.data.inventory {
                    throw CartError.productUnavailable
                }
            }
        }

        if !itemExists {
            cart.items.append(unit)
        }

        return try repository.updateCart(data: cart)
    }

    public func applyGiftCard(forAccount userId: UUID, code: String) throws -> Cart {
        let _ = try accountsService.getAccount(id: userId)
        var cart = try repository.getCart(forId: userId)
        if cart.items.isEmpty {     // cannot apply card when there aren't any items.
            throw CartError.noItemsInCart
        }

        var card = try giftsService.getCard(forCode: code)
        var zero = UnitMeasurement(value: 0.0, unit: cart.currency!)
        // This only validates the card - because we're passing zero.
        try card.data.deductPrice(from: &zero)
        cart.giftCards.append(card.id)

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

        let orderData = OrderData(shippingAddress: shippingAddress, billingAddress: billingAddress,
                                  placedBy: userId, products: units)
        let order = try ordersService.createOrder(data: orderData)

        cart.reset()
        let _ = try repository.updateCart(data: cart)
        return order
    }
}
