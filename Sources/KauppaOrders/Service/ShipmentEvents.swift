import KauppaCore
import KauppaOrdersModel
import KauppaShipmentsModel

extension OrdersService {
    /// Shipment has reached the customer. Set the fulfillment quantity for
    /// each order unit, which indicates the number of items delivered.
    ///
    /// - Parameters:
    ///   - for: The `Order` in which the changes have to be made.
    ///   - with: The `Shipment` data
    /// - Throws: `ServiceError` if there was an error.
    func handleDeliveryEvent(for order: inout Order, with data: Shipment) throws -> () {
        for unit in data.items {
            let i = try OrdersService.findEnumeratedProduct(in: order, for: unit.product,
                                                            expectFulfillment: false)
            let expectedQuantity = order.products[i].quantity
            if unit.quantity > expectedQuantity {
                throw ServiceError.invalidDeliveryQuantity
            }

            order.products[i].status = OrderUnitStatus(for: unit.quantity)
        }
    }

    /// Handle the pickup event from shipments service, such that the items successfully picked up
    /// have been reflected in the corresponding `Order` data.
    ///
    /// - Parameters:
    ///   - for: The `Order` in which the changes have to be made.
    ///   - with: The `Shipment` data
    /// - Throws: `ServiceError` if there was an error.
    func handlePickupEvent(for order: inout Order, with data: Shipment) throws -> () {
        for unit in data.items {
            let i = try OrdersService.findEnumeratedProduct(in: order, for: unit.product)
            let scheduled = order.products[i].status!.pickupQuantity    // safe to unwrap here
            if unit.quantity > scheduled {      // picked up more than what was scheduled
                throw ServiceError.invalidPickupQuantity
            }

            order.products[i].status!.pickupQuantity -= unit.quantity

            let delivered = order.products[i].status!.fulfilledQuantity
            if unit.quantity > delivered {
                throw ServiceError.unfulfilledItem
            }

            order.products[i].status!.fulfilledQuantity -= unit.quantity
            order.products[i].status!.refundableQuantity += unit.quantity
        }
    }
}
