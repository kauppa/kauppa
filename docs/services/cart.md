# KauppaCart

KauppaCart maintains the cart belonging to an account. It exposes `CartServiceCallable` interface, which is implemented by both the service and the client.

## Overview

### Cart unit

A cart unit represents an individual product along with the specified quantity. When adding a "cart unit" to the cart, the price is automatically calculated along with the tax (based on the region). If another unit of the same product is added to the cart, then the new quantity is added to the previous quantity.

### Cart

By default, all user accounts (in KauppaAccounts) have a cart associated with it. Hence, an user's `UUID` is the same as that of the cart. It has the list of items ("cart units") that the user may (or may not) check out in the future. It also has the list of coupons applied by the user (if any).

**NOTE:** Currently, Kauppa requires that all products should have the same currency. The service will return an error if the new item is of a different currency. This is to ensure that regional products can't be added to (or checked out from) cart from a different region.

### Checkout

After adding items (and possibly after applying coupons), the user can perform a checkout, when the cart service places an order and (if that was successful) the cart will be reset. For checking out, the shipping address is mandatory, and it should point to an address in the user's account. If the billing address wasn't provided, then shipping address is used in place of it.

## Usage

### Initializing the service

If you're planning to use the service itself, then you'd need `KauppaCart` package as a whole (since the service needs the client interface, repository and store).

Also, the cart service depends on products service (for verifying added items), accounts service (for verifying user), coupon service (for verifying applied coupons), orders service (for placing order during checkout) and tax service (for calculating gross price for cart items). It doesn't need the actual services themselves, it takes anything that implements the service interfaces (which could be a client, or anything that provides some defined way to talk to those services).

``` swift
import KauppaCartRepository
import KauppaCartService
import KauppaCartStore

let store = ... // store of your choice
let repository = CartRepository(with: store)
let service = CartService(with: repository,    
                          // services/clients/anything that implements the interfaces
                          productsService: ...,
                          accountsService: ...,
                          couponService: ...,
                          ordersService: ...,
                          taxService: ...)
```

### Initializing the client

``` swift
import KauppaCartClient

let client = CartClient(host: "https://naamio.cloud/cart")
client.use(token: "deadbeef")
```

Since both the service and the client implement the same protocol, the API remains the same.

### Example

``` swift
import KauppaCartModel

// [Add item to an user's cart]
// Here, `productId` should be a valid product ID (i.e., product service should return a product),
// and the desired quantity should be less than the items in the inventory.
let unit = CartUnit(product: productId, quantity: 10)
// `userId` should be a valid account ID (i.e., accounts service should return an account).
// `address` is used for querying the tax service for tax rate (so, that should be valid too)
var cart = try! service.addCartItem(for: userId, with: unit, from: address)

// [Apply coupon to the cart]
// `couponCode` should be a valid coupon code (i.e., coupon service should return a coupon)
cart = try! service.applyCoupon(for: userId, using: couponCode, from: address)

// [Checkout]
// by default, this takes the first address from the user's account (which should exist)
let order = try! service.placeOrder(for: userId, with: CheckoutData())
```
