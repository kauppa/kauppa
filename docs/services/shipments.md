# KauppaShipments

KauppaShipments manages the shipment information for orders. It exposes `ShipmentsServiceCallable` interface, which
is implemented by both the service and the client.

## Overview

### Shipment

A shipment is always associated with an order. It holds the address and the list of items to be delivered to (or picked up from) a customer. Once an order has been placed, it creates a shipment (which is in the `shipping` state by default). Once the admin confirms the order, they can mark the shipment as `shipping` (when the service notifies the orders service).  or once the pickup is completed (so that the corresponding order is changed by the orders service).

### Delivery

The admin should mark the shipment once it has been delivered to the customer, when this service notifies orders service about the delivery.

### Pickup

When the customer chooses to return a list of items belonging to an order, a pickup is scheduled automatically by the orders service, which is then verified by the admin and initiated. Once the pickup is complete, the admin should mark the shipment which will notify the orders service that the items have been returned

## Usage

### Initializing the service

If you're planning to use the service itself, then you'd need `KauppaShipments` package as a whole (since the service needs the client interface, repository and store), and a client/service implementing the `OrdersServiceCallable` protocol (since shipments rely on orders).

``` swift
import KauppaShipmentsRepository
import KauppaShipmentsService
import KauppaShipmentsStore

let store = ... // store of your choice
let repository = ShipmentsRepository(with: store)
let service = ShipmentsService(with: repository,
                               // anything that implements the `OrdersServiceCallable` interface
                               ordersService: ...)
```

### Initializing the client

``` swift
import KauppaShipmentsClient

let client = ShipmentsClient(host: "https://naamio.cloud/shipments")
client.use(token: "deadbeef")
```

Since both the service and the client implement the same protocol, the API remains the same.

### Example

``` swift
import KauppaShipmentsModel

// create a shipment for an order
// (here, `orderId` should be valid i.e., should be returned by orders service).
var shipment = try! service.createShipment(for: orderId)
// shipment has been confirmed
shipment = try! service.notifyShipping(for: shipment.id)
// shipment has been delivered
shipment = try! service.notifyDelivery(for: shipment.id)
```
