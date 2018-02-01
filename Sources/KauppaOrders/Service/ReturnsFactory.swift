import Foundation

import KauppaCartModel
import KauppaOrdersModel
import KauppaProductsClient
import KauppaProductsModel
import KauppaShipmentsClient
import KauppaShipmentsModel

/// Factory for scheduling pickup of items.
class ReturnsFactory {
    let data: PickupData
    let productsService: ProductsServiceCallable

    private var returnItems = [GenericCartUnit<Product>]()

    init(with data: PickupData, using service: ProductsServiceCallable) {
        self.data = data
        productsService = service
    }

    /// Collects the items that can be picked up from this order. This actually
    /// changes the `pickupQuantity` in each order unit (to indicate that the items have
    /// been scheduled for pickup).
    func getAllItemsForPickup(forOrder order: inout Order) throws {
        for (i, unit) in order.products.enumerated() {
            let product = try productsService.getProduct(id: unit.item.product)
            // Only collect "untouched" items (if any) from each unit
            // (i.e., items that have been fulfilled and not scheduled for pickup)
            let fulfilled = unit.untouchedItems()
            if fulfilled > 0 {
                let returnUnit = GenericCartUnit(product: product, quantity: fulfilled)
                returnItems.append(returnUnit)
                order.products[i].status!.pickupQuantity += returnUnit.quantity
            }
        }
    }

    /// Same as `getAllItemsForPickup`, only difference is that it gets the items from the data.
    func getSpecifiedItemsForPickup(forOrder order: inout Order) throws {
        for unit in data.units ?? [] {
            let i = try OrdersService.findEnumeratedProduct(inOrder: order, forId: unit.product)
            let product = try productsService.getProduct(id: unit.product)

            // Only items that have been fulfilled "and" not scheduled for pickup
            let fulfilled = order.products[i].untouchedItems()
            if unit.quantity > fulfilled {
                throw OrdersError.invalidReturnQuantity(product.id, fulfilled)
            }

            returnItems.append(GenericCartUnit(product: product, quantity: unit.quantity))
            order.products[i].status!.pickupQuantity += unit.quantity
        }
    }

    func initiatePickup(forOrder order: inout Order,
                        withShipping shippingService: ShipmentsServiceCallable) throws
    {
        try order.validateForReturn()

        if data.pickupAll ?? false {
            try getAllItemsForPickup(forOrder: &order)
        } else {
            try getSpecifiedItemsForPickup(forOrder: &order)
        }

        if returnItems.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        var pickupData = PickupItems()
        for unit in returnItems {
            pickupData.items.append(CartUnit(product: unit.product.id, quantity: unit.quantity))
        }

        let shipment = try shippingService.schedulePickup(forOrder: order.id, data: pickupData)
        order.shipments[shipment.id] = shipment.status
    }
}
