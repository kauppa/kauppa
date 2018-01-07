import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaShipmentsClient
import KauppaShipmentsModel
import KauppaShipmentsRepository

/// Public API for the cart belonging to a customer account.
public class ShipmentsService {
    let repository: ShipmentsRepository
    let ordersService: OrdersServiceCallable

    /// Initializes a new `ShipmentsService` instance with a
    /// repository and orders service client.
    public init(withRepository repository: ShipmentsRepository,
                ordersService: OrdersServiceCallable)
    {
        self.repository = repository
        self.ordersService = ordersService
    }
}

// NOTE: See the actual protocol in `KauppaShipmentsClient` for exact usage.
extension ShipmentsService: ShipmentsServiceCallable {
    public func createShipment(forOrder id: UUID) throws -> Shipment {
        let order = try ordersService.getOrder(forId: id)
        let address = order.shippingAddress
        return try repository.createShipment(forOrder: id, address: address, items: order.products)
    }

    public func notifyShipping(id: UUID) throws -> Shipment {
        var data = try repository.getShipment(id: id)
        if data.status != .shipping {
            throw ShipmentsError.notQueuedForShipping
        }

        data.status = .shipped
        try ordersService.updateShipment(forId: data.orderId, data: data)
        return try repository.updateShipment(data: data)
    }

    public func notifyDelivery(id: UUID) throws -> Shipment {
        var data = try repository.getShipment(id: id)
        if data.status != .shipped {
            throw ShipmentsError.notQueuedForShipping
        }

        data.status = .shipped
        try ordersService.updateShipment(forId: data.orderId, data: data)
        return try repository.updateShipment(data: data)
    }

    public func schedulePickup(forOrder id: UUID, data: PickupItems) throws -> Shipment {
        let order = try ordersService.getOrder(forId: id)
        let address = order.shippingAddress
        return try repository.createShipment(forOrder: id, address: address,
                                             items: data.items, status: .pickup)
    }

    public func completePickup(id: UUID) throws -> Shipment {
        var data = try repository.getShipment(id: id)
        if data.status != .pickup {
            throw ShipmentsError.notScheduledForPickup
        }

        data.status = .returned
        try ordersService.updateShipment(forId: data.orderId, data: data)
        return try repository.updateShipment(data: data)
    }
}
