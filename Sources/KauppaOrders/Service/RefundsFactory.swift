import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaProductsClient
import KauppaProductsModel

/// Factory class for creating order refunds.
class RefundsFactory {
    let data: RefundData
    let repository: OrdersRepository
    let productsService: ProductsServiceCallable

    private var atleastOneItemExists = false
    private var refundItems = [GenericOrderUnit<Product>]()

    init(with data: RefundData, using repository: OrdersRepository,
         service: ProductsServiceCallable)
    {
        self.data = data
        self.repository = repository
        productsService = service
    }

    /// Fills `refundItems` with all refundable items in this order. If there aren't any fulfilled
    /// quantity after processing the refundable items in an unit, then the unit status
    /// will be set to `nil`
    func getAllRefundableItems(forOrder data: inout Order) throws {
        for (i, unit) in data.products.enumerated() {
            let product = try productsService.getProduct(id: unit.product)
            // Only collect fulfilled items (if any) from each unit.
            if let unitStatus = unit.status {
                if unitStatus.refundableQuantity > 0 {
                    let refundUnit = GenericOrderUnit(product: product,
                                                      quantity: unitStatus.refundableQuantity)
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
    func getSpecifiedItemsForRefund(forOrder order: inout Order) throws {
        for unit in data.units ?? [] {
            let i = try OrdersService.findEnumeratedProduct(inOrder: order, forId: unit.product)
            let product = try productsService.getProduct(id: unit.product)
            // It's safe to unwrap here because the function checks this.
            let unitStatus = order.products[i].status!
            let refundable = unitStatus.refundableQuantity

            if unit.quantity > refundable {
                throw OrdersError.invalidRefundQuantity(product.id, refundable)
            }

            refundItems.append(GenericOrderUnit(product: product, quantity: unit.quantity))
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
    func setStatus(forOrder order: inout Order) throws {
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
    func createRefund(forOrder id: UUID) throws -> Refund {
        // We can assume that all products in a successfully placed
        // order *will* have the same currency, because the cart checks it.
        let currency = refundItems[0].product.data.price.unit
        var totalPrice = UnitMeasurement(value: 0.0, unit: currency)
        var items = [OrderUnit]()
        for item in refundItems {
            totalPrice.value += item.product.data.price.value * Double(item.quantity)
            let unit = OrderUnit(product: item.product.id, quantity: item.quantity)
            items.append(unit)
        }

        return try repository.createRefund(forOrder: id, reason: data.reason,
                                           items: items, amount: totalPrice)
    }

    func initiateRefund(forId id: UUID) throws -> Order {
        if data.reason.isEmpty {
            throw OrdersError.invalidReason
        }

        var order = try repository.getOrder(id: id)
        try order.validateForRefund()

        if data.fullRefund ?? false {
            try getAllRefundableItems(forOrder: &order)
        } else {
            try getSpecifiedItemsForRefund(forOrder: &order)
        }

        if refundItems.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        try setStatus(forOrder: &order)
        let refund = try createRefund(forOrder: order.id)
        order.refunds.append(refund.id)
        return order
    }
}
