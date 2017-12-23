import Foundation

import KauppaCore
import KauppaOrdersClient
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

extension ShipmentsService: ShipmentsServiceCallable {
    public func createShipment(forOrder id: UUID) throws -> Shipment {
        let order = try ordersService.getOrder(forId: id)
        return try repository.createShipment(forOrder: id, items: order.products)
    }
}
