import Foundation

import KauppaCore
import KauppaCartModel
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaProductsClient
import KauppaProductsModel

/// Factory class for creating order refunds. This iterates over the given
/// items, checks whether they exist in the order, whether they've been
/// fulfilled and creates a refund for the order.
class RefundsFactory {
    let data: RefundData
    let productsService: ProductsServiceCallable

    private var atleastOneItemExists = false
    private var refundItems = [GenericCartUnit<Product>]()

    /// Initialize this factory with refund data and products service.
    ///
    /// - Parameters:
    ///   - with: `RefundData` object for creating the refund.
    ///   - using: Anything that implements `ProductsServiceCallable`
    init(with data: RefundData, using service: ProductsServiceCallable) {
        self.data = data
        productsService = service
    }

    /// Method to initiate refund using the given order data (entrypoint for factory production).
    ///
    /// - Parameters:
    ///   - for: The ID of the order in which this refund should be issued.
    ///   - using: `OrdersRepository`
    /// - Throws: `ServiceError`
    ///   - If there were failures in refund creation.
    ///   - If there was an error in getting the product.
    func initiateRefund(for order: inout Order,
                        using repository: OrdersRepository) throws
    {
        try data.validate()
        try order.validateForRefund()

        if data.fullRefund ?? false {
            try getAllRefundableItems(for: &order)
        } else {
            try getSpecifiedItemsForRefund(for: &order)
        }

        if refundItems.isEmpty {
            throw ServiceError.noItemsToProcess
        }

        try setStatus(for: &order)
        let refund = try createRefund(for: order.id, using: repository)
        order.refunds.append(refund.id)
    }

    /// Fills `refundItems` with all refundable items in this order. If there aren't any fulfilled
    /// quantity after processing the refundable items in an unit, then the unit status
    /// will be set to `nil`
    private func getAllRefundableItems(for data: inout Order) throws {
        for (i, unit) in data.products.enumerated() {
            let product = try productsService.getProduct(for: unit.item.product,
                                                         from: data.shippingAddress)
            // Only collect fulfilled items (if any) from each unit.
            if let unitStatus = unit.status {
                if unitStatus.refundableQuantity > 0 {
                    let refundUnit = GenericCartUnit(for: product,
                                                     with: unitStatus.refundableQuantity)
                    data.products[i].status!.refundableQuantity = 0    // reset refundable quantity
                    refundItems.append(refundUnit)
                }

                // This is the last step in return + refund process. So, if there are
                // no fulfilled items, then we can safely reset this state.
                if unitStatus.fulfilledQuantity == 0 {
                    data.products[i].status = nil
                }
            }
        }
    }

    /// Fills `refundItems` with items from the given data that matches the refundable items
    /// in the order. If the quantity becomes zero after processing the refundable items in an unit,
    /// then its status will be set to `nil`
    private func getSpecifiedItemsForRefund(for order: inout Order) throws {
        for unit in data.units ?? [] {
            let i = try OrdersService.findEnumeratedProduct(in: order, for: unit.product)
            let product = try productsService.getProduct(for: unit.product,
                                                         from: order.shippingAddress)
            // It's safe to unwrap here because the function checks this.
            let unitStatus = order.products[i].status!
            let refundable = unitStatus.refundableQuantity

            if unit.quantity > refundable {
                throw ServiceError.invalidRefundQuantity
            }

            refundItems.append(GenericCartUnit(for: product, with: unit.quantity))
            order.products[i].status!.refundableQuantity -= unit.quantity

            // Check whether all items have been refunded in this unit
            if unitStatus.fulfilledQuantity == 0 && refundable == unit.quantity {
                order.products[i].status = nil
            } else {
                order.products[i].status!.fulfillment = .partial
            }

            atleastOneItemExists = atleastOneItemExists || order.products[i].hasFulfillment
        }
    }

    /// Set the payment and fulfillment status of the order.
    private func setStatus(for order: inout Order) throws {
        // If we've come this far, then it's either a partial refund or full refund.
        if atleastOneItemExists {
            order.paymentStatus = .partialRefund
            order.fulfillment = .partial
        } else {
            order.paymentStatus = .refunded
            order.fulfillment = nil
        }
    }

    /// Create a `Refund` object with the collected items.
    private func createRefund(for id: UUID,
                              using repository: OrdersRepository) throws -> Refund
    {
        var totalPrice = Price()
        var items = [CartUnit]()
        for item in refundItems {
            totalPrice += Price(item.product.price.value * Float(item.quantity))
            let unit = CartUnit(for: item.product.id!, with: item.quantity)
            items.append(unit)
        }

        return try repository.createRefund(for: id, with: data.reason,
                                           items: items, amount: totalPrice)
    }
}
