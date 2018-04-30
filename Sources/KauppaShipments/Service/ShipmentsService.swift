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

    /// Initializes a new `ShipmentsService` instance with a repository and
    /// orders service client.
    ///
    /// - Parameters:
    ///   - with: `ShipmentsRepository`
    ///   - ordersService: Anything that implements `OrdersServiceCallable`
    public init(with repository: ShipmentsRepository,
                ordersService: OrdersServiceCallable)
    {
        self.repository = repository
        self.ordersService = ordersService
    }
}

// NOTE: See the actual protocol in `KauppaShipmentsClient` for exact usage.
extension ShipmentsService: ShipmentsServiceCallable {
    public func createShipment(for orderId: UUID) throws -> Shipment {
        let order = try ordersService.getOrder(for: orderId)
        let address = order.shippingAddress
        let items = order.products.map { $0.item }
        return try repository.createShipment(for: orderId, with: items, to: address)
    }

    public func notifyShipping(for id: UUID) throws -> Shipment {
        var data = try repository.getShipment(for: id)
        if data.status != .shipping {
            throw ServiceError.notQueuedForShipping
        }

        data.status = .shipped
        try ordersService.updateShipment(for: data.orderId, with: data)
        return try repository.updateShipment(with: data)
    }

    public func notifyDelivery(for id: UUID) throws -> Shipment {
        var data = try repository.getShipment(for: id)
        if data.status != .shipped {
            throw ServiceError.notBeingShipped
        }

        data.status = .delivered
        try ordersService.updateShipment(for: data.orderId, with: data)
        return try repository.updateShipment(with: data)
    }

    public func schedulePickup(for orderId: UUID, with data: PickupItems) throws -> Shipment {
        let order = try ordersService.getOrder(for: orderId)
        let address = order.shippingAddress
        return try repository.createShipment(for: orderId, with: data.items,
                                             to: address, status: .pickup)
    }

    public func completePickup(for id: UUID) throws -> Shipment {
        var data = try repository.getShipment(for: id)
        if data.status != .pickup {
            throw ServiceError.notScheduledForPickup
        }

        data.status = .returned
        try ordersService.updateShipment(for: data.orderId, with: data)
        return try repository.updateShipment(with: data)
    }
}
