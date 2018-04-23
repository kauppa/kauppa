import Foundation

import KauppaCore
import KauppaCartModel
import KauppaOrdersModel
import KauppaProductsClient
import KauppaProductsModel
import KauppaShipmentsClient
import KauppaShipmentsModel

/// Factory for scheduling pickup of items. This checks for the items' existence in the order,
/// collects them, validates whether they can be returned (and how many) and finally schedules
/// pickup for those items in the shipments service.
class ReturnsFactory {
    let data: PickupData
    let productsService: ProductsServiceCallable

    private var returnItems = [GenericCartUnit<Product>]()

    /// Initialize this factory with pickup data and product service.
    ///
    /// - Parameters:
    ///   - with: `PickupData`
    ///   - using: Anything that implements `ProductsServiceCallable`
    init(with data: PickupData, using service: ProductsServiceCallable) {
        self.data = data
        productsService = service
    }

    /// Method to initiate pickup based on the given order data (entrypoint for factory production).
    ///
    /// - Parameters:
    ///   - for: The actual `Order` associated with this pickup.
    ///   - using: Anything that implements `ShipmentsServiceCallable`
    /// - Throws: `ServiceError`
    ///   - If the product doesn't exist.
    ///   - If the specified item(s) cannot be returned.
    ///   - If there was an error in scheduling the pickup.
    func initiatePickup(for order: inout Order,
                        with shippingService: ShipmentsServiceCallable) throws
    {
        try order.validateForReturn()

        if data.pickupAll ?? false {
            try getAllItemsForPickup(for: &order)
        } else {
            try getSpecifiedItemsForPickup(for: &order)
        }

        if returnItems.isEmpty {
            throw ServiceError.noItemsToProcess
        }

        var pickupData = PickupItems()
        for unit in returnItems {
            pickupData.items.append(CartUnit(for: unit.product.id!, with: unit.quantity))
        }

        let shipment = try shippingService.schedulePickup(for: order.id, with: pickupData)
        order.shipments[shipment.id] = shipment.status
    }

    /// Collects the items that can be picked up from this order. This actually
    /// changes the `pickupQuantity` in each order unit (to indicate that the items have
    /// been scheduled for pickup).
    private func getAllItemsForPickup(for order: inout Order) throws {
        for (i, unit) in order.products.enumerated() {
            let product = try productsService.getProduct(for: unit.item.product,
                                                         from: order.shippingAddress)
            // Only collect "untouched" items (if any) from each unit
            // (i.e., items that have been fulfilled and not scheduled for pickup)
            let fulfilled = unit.untouchedItems()
            if fulfilled > 0 {
                let returnUnit = GenericCartUnit(for: product, with: fulfilled)
                returnItems.append(returnUnit)
                order.products[i].status!.pickupQuantity += returnUnit.quantity
            }
        }
    }

    /// Same as `getAllItemsForPickup`, only difference is that it gets the items from the data.
    private func getSpecifiedItemsForPickup(for order: inout Order) throws {
        for unit in data.units ?? [] {
            let i = try OrdersService.findEnumeratedProduct(in: order, for: unit.product)
            let product = try productsService.getProduct(for: unit.product,
                                                         from: order.shippingAddress)

            // Only items that have been fulfilled "and" not scheduled for pickup
            let fulfilled = order.products[i].untouchedItems()
            if unit.quantity > fulfilled {
                throw ServiceError.invalidReturnQuantity
            }

            returnItems.append(GenericCartUnit(for: product, with: unit.quantity))
            order.products[i].status!.pickupQuantity += unit.quantity
        }
    }
}
