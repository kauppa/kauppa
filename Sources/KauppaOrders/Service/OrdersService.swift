import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel
import KauppaOrdersClient
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaProductsClient
import KauppaProductsModel

/// Service that manages orders placed by customers.
public class OrdersService: OrdersServiceCallable {
    let repository: OrdersRepository
    let accountsService: AccountsServiceCallable
    let productsService: ProductsServiceCallable

    var mailService: MailClient? = nil

    /// Initialize this service with its repository, along with
    /// instances of clients to account and product services.
    public init(withRepository repository: OrdersRepository,
                accountsService: AccountsServiceCallable,
                productsService: ProductsServiceCallable)
    {
        self.repository = repository
        self.accountsService = accountsService
        self.productsService = productsService
    }

    public func createOrder(data: OrderData) throws -> Order {
        let weightCounter = WeightCounter()
        var order = Order()
        var inventoryUpdates = [UUID: UInt32]()
        var detailedOrder: DetailedOrder = GenericOrder()   // order data for mail service

        let account = try accountsService.getAccount(id: data.placedBy)
        order.placedBy = data.placedBy
        detailedOrder.placedBy = account

        var productPrice = 0.0
        var priceUnit: Currency? = nil
        var totalPrice = 0.0

        for orderUnit in data.products {
            let product = try productsService.getProduct(id: orderUnit.product)
            if orderUnit.quantity == 0 {
                continue    // skip zero'ed items
            }

            // check that all products are in the same currency
            productPrice = product.data.price.value
            if let unit = priceUnit {
                if unit != product.data.price.unit {
                    throw OrdersError.ambiguousCurrencies
                }
            } else {
                priceUnit = product.data.price.unit
            }

            // Also check for duplicate product
            let available = inventoryUpdates[product.id] ?? product.data.inventory
            if available < orderUnit.quantity {
                throw OrdersError.productUnavailable
            }

            let leftover = available - UInt32(orderUnit.quantity)
            inventoryUpdates[product.id] = leftover
            order.products.append(orderUnit)
            let unit = GenericOrderUnit(product: product,
                                        quantity: orderUnit.quantity)
            detailedOrder.products.append(unit)

            totalPrice += Double(orderUnit.quantity) * productPrice
            var weight = product.data.weight ?? UnitMeasurement(value: 0.0, unit: .gram)
            weight.value *= Double(orderUnit.quantity)
            weightCounter.add(weight)
            order.totalItems += UInt16(orderUnit.quantity)
        }

        if inventoryUpdates.isEmpty {
            throw OrdersError.noItemsToProcess
        }

        for (id, leftover) in inventoryUpdates {
            var patch = ProductPatch()
            patch.inventory = leftover
            // FIXME: What if the client fails for some reason?
            let _ = try? productsService.updateProduct(id: id, data: patch)
        }

        order.totalPrice = UnitMeasurement(value: totalPrice, unit: priceUnit!)
        order.totalWeight = weightCounter.sum()
        let orderData = try repository.createOrder(withData: order)
        orderData.copyValues(into: &detailedOrder)
        let mailOrder = MailOrder(from: detailedOrder)
        if let mailer = mailService {
            mailer.sendMail(to: account.data.email, with: mailOrder)
        }

        return orderData
    }

    public func cancelOrder(id: UUID) throws -> Order {
        var order = try repository.getOrder(id: id)
        let date = Date()
        order.cancelledAt = date
        order.updatedAt = date
        return try repository.updateOrder(withData: order, skipDate: true)
    }

    public func initiateRefund(forId id: UUID, data: RefundData) throws -> Order {
        if data.reason.isEmpty {
            throw OrdersError.invalidRefundReason
        }

        var order = try repository.getOrder(id: id)
        if let _ = order.cancelledAt {
            throw OrdersError.cancelledOrder
        }

        switch order.paymentStatus {
            case .refunded:
                throw OrdersError.refundedOrder
            case .failed, .pending:
                throw OrdersError.paymentNotReceived
            default:
                break
        }

        var refundItems = [GenericOrderUnit<Product>]()
        // TODO: Investigate payment processing
        // TODO: Support restocking inventory

        if data.fullRefund ?? false {
            order.paymentStatus = .refunded
            for i in 0..<order.products.count {
                let product = try productsService.getProduct(id: order.products[i].product)
                if let unitStatus = order.products[i].status {
                    if unitStatus.fulfilledQuantity > 0 {
                        let unit = GenericOrderUnit(product: product,
                                                    quantity: unitStatus.fulfilledQuantity)
                        refundItems.append(unit)
                    }
                }

                // Null represents that none of the items have been fulfilled.
                order.products[i].status = nil
            }
        } else {
            guard let units = data.units else {
                throw OrdersError.noItemsToProcess
            }

            for unit in units {
                var product: Product? = nil
                var unitIdx: Int? = nil
                for i in 0..<order.products.count {
                    let id = order.products[i].product
                    if unit.product != id {
                        continue
                    }

                    product = try productsService.getProduct(id: id)
                    unitIdx = i
                }

                guard let productData = product, let i = unitIdx else {
                    throw OrdersError.invalidOrderItem
                }

                guard let unitStatus = order.products[i].status else {
                    throw OrdersError.unrefundableItem(productData.id)
                }

                let fulfilled = unitStatus.fulfilledQuantity
                if fulfilled == 0 {
                    throw OrdersError.unrefundableItem(productData.id)
                } else if unit.quantity > fulfilled {
                    throw OrdersError.invalidOrderQuantity(productData.id, fulfilled)
                }

                let unit = GenericOrderUnit(product: productData,
                                            quantity: unit.quantity)
                refundItems.append(unit)
                order.products[i].status!.fulfilledQuantity -= unit.quantity
                order.products[i].status!.fulfillment = .partial
            }
        }

        return try repository.updateOrder(withData: order)
    }

    public func deleteOrder(id: UUID) throws -> () {
        return try repository.deleteOrder(id: id)
    }
}
