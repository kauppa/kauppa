# KauppaOrders

KauppaOrders maintains the orders checked out by customers (it also communicates with the shipping and payments service for tracking the order status). It exposes `OrdersServiceCallable` interface, which is implemented by both the service and the client.

## Overview

### Order unit

An order unit represents a product, its quantity, and its status. The status itself has three other quantities along with the actual fulfillment status.

 - There's the `fulfilledQuantity` which indicates the number of items that have been delivered to the customer.
 - Then, there's the `pickupQuantity`, which indicates the number of items (in that unit) scheduled for pickup.
 - Finally, there's the `refundableQuantity`, which indicates the number of items to be refunded.

The `fulfilledQuantity` is zero until all/some of it reaches the customer. Once the items have been scheduled for pickup, `pickupQuantity` is changed, and once they've been picked up, the value is deducted from the `fulfilledQuantity` and added to the `refundableQuantity` - once the items have been refunded, this value is set to zero again.

There's also `FulfillmentStatus` which indicates whether this order unit is partially/completely fulfilled.

### Order

An order is a collection of items demanded by the customer for fulfilling their own selfish desires. An order is placed when a "verified" customer checks out their cart. It has an unique ID, the list of items, weight, price and tax information, applied coupons, shipment, payment and refund information, etc.

 - On placing an order, the orders service verifies the products against their inventory, calculates the prices and tax, applies coupons, schedules for shipment and finally mails the customer's verified mail addresses detailing the successfully placed order.
 - The order can then be cancelled by the customer, or (if it's been fulfilled) the customer can choose to return any/all of the items in the order (when a pickup is scheduled in the shipments service).
 - If some/all of the items have been picked up from the customer, then they're eligible for a refund (which is one of the features of this service).

## Usage

### Initializing the service

If you're planning to use the service itself, then you'd need `KauppaOrders` package as a whole (since the service needs the client interface, repository and store), along with the products, accounts, coupon shipping and tax services (or anything implementing those interfaces).

``` swift
import KauppaOrdersRepository
import KauppaOrdersService
import KauppaOrdersStore

let store = ... // store of your choice
let repository = OrdersRepository(with: store)
let service = OrdersService(with: repository,
                            accountsService: ...,
                            productsService: ...,
                            shippingService: ...,
                            couponService: ...,
                            taxService: ...)
```

### Initializing the client

``` swift
import KauppaOrdersClient

let client = OrdersClient(host: "https://naamio.cloud/orders")
client.use(token: "deadbeef")
```

Since both the service and the client implement the same protocol, the API remains the same.

### Example

``` swift
import KauppaOrdersModel

// Let's create a simple order...
// ideally, an order is created by the cart service during checkout, but anyway...

// productId should be a valid product (with at least 3 items in inventory) in products service
let unit = OrderUnit(product: productId, quantity: 3)   
// accountId should belong to a valid (and verified) account in the accounts service
let orderData = OrdersService(shippingAddress: Address(), billingAddress: nil,
                              placedBy: accountId, products: [unit])
var order = try! service.createOrder(with: orderData)

// tell the service to pickup all items (you can also return selected items and quantities though)
var pickupData = PickupData()
pickupData.pickupAll = true
order = try! ordersService.returnOrder(for: order.id, with: pickupData)

// before refunding, the orders service should be notified of payment from payments service
// and picked up items from the shipping service (otherwise, this wouldn't work)

let refundData = RefundData(reason: "I hate you!")
order = try! service.initiateRefund(for: order.id, with: refundData)
```
