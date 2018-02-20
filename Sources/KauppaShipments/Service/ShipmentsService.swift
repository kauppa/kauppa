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
    public init(with repository: ShipmentsRepository,
                ordersService: OrdersServiceCallable)
    {
        self.repository = repository
        self.ordersService = ordersService
    }
}

// NOTE: See the actual protocol in `KauppaShipmentsClient` for exact usage.
extension ShipmentsService: ShipmentsServiceCallable {
    public func createShipment(for id: UUID) throws -> Shipment {
        let order = try ordersService.getOrder(forId: id)
        let address = order.shippingAddress
        let items = order.products.map { $0.item }
        return try repository.createShipment(for: id, address: address, items: items)
    }

    public func notifyShipping(for id: UUID) throws -> Shipment {
        var data = try repository.getShipment(for: id)
        if data.status != .shipping {
            throw ShipmentsError.notQueuedForShipping
        }

        data.status = .shipped
        try ordersService.updateShipment(forId: data.orderId, data: data)
        return try repository.updateShipment(with: data)
    }

    public func notifyDelivery(for id: UUID) throws -> Shipment {
        var data = try repository.getShipment(for: id)
        if data.status != .shipped {
            throw ShipmentsError.notBeingShipped
        }

        data.status = .delivered
        try ordersService.updateShipment(forId: data.orderId, data: data)
        return try repository.updateShipment(with: data)
    }

    public func schedulePickup(for id: UUID, with data: PickupItems) throws -> Shipment {
        let order = try ordersService.getOrder(forId: id)
        let address = order.shippingAddress
        return try repository.createShipment(for: id, address: address,
                                             items: data.items, status: .pickup)
    }

    public func completePickup(for id: UUID) throws -> Shipment {
        var data = try repository.getShipment(for: id)
        if data.status != .pickup {
            throw ShipmentsError.notScheduledForPickup
        }

        data.status = .returned
        try ordersService.updateShipment(forId: data.orderId, data: data)
        return try repository.updateShipment(with: data)
    }
}
