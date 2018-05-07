import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaShipmentsModel
import KauppaShipmentsRepository

/// Factory class for creating shipments for order items.
class ShipmentsFactory {
    let order: Order
    let items: [OrderUnit]?

    private var orderItems = [UUID: UInt8]()
    private var shipmentItems = [OrderUnit]()

    /// Initialize this factory with an order and (optional) list of items.
    ///
    /// - Parameters:
    ///   - for: The `Order` associated with this shipment.
    ///   - with: The list of `OrderUnit` objects with item IDs and quantities.
    init(for order: Order, with items: [OrderUnit]?) {
        self.order = order
        self.items = items

        order.products.forEach { unit in
            orderItems[unit.product] = unit.quantity
        }
    }

    /// Create a shipment using the initialized data and shipments repository.
    ///
    /// - Parameters:
    ///   - using: `ShipmentsRepository`
    /// - Returns: `Shipment` for the line items.
    /// - Throws: `ServiceError` if there are no items, or if any of the items are invalid.
    func createShipment(using repository: ShipmentsRepository) throws -> Shipment {
        if items != nil && !items!.isEmpty {
            try processItems()
        } else {
            shipmentItems = order.products
        }

        if shipmentItems.isEmpty {
            throw ServiceError.noItemsToProcess
        }

        return try repository.createShipment(for: order.id, with: shipmentItems,
                                             to: order.shippingAddress)
    }

    /// The service has been provided with a non-empty list of line items. Validate and process them.
    private func processItems() throws {
        var itemQuantities = [UUID: UInt8]()
        try items!.forEach { unit in
            let unit = unit
            guard let orderQuantity = orderItems[unit.product] else {
                throw ServiceError.invalidItemId    // Make sure that item exists in order.
            }

            if unit.quantity == 0 {
                return      // Skipping zero quantity units
            }

            if itemQuantities[unit.product] == nil {
                itemQuantities[unit.product] = 0
            }

            // This way, we mutate if the item already exists.
            itemQuantities[unit.product]! += unit.quantity

            // Clamp the unit's quantity to the allowed quantity (from order).
            if itemQuantities[unit.product]! > orderQuantity {
                itemQuantities[unit.product]! = orderQuantity
            }
        }

        for (item, quantity) in itemQuantities {
            shipmentItems.append(OrderUnit(for: item, with: quantity))
        }
    }
}
