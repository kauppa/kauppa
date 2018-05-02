import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaOrdersClient
import KauppaShipmentsModel

/// Router specific to the orders service.
public class OrdersRouter<R: Routing>: ServiceRouter<R, OrdersRoutes> {
    let service: OrdersServiceCallable

    /// Initializes this router with a `Routing` object and
    /// an `OrdersServiceCallable` object.
    public init(with router: R, service: OrdersServiceCallable) {
        self.service = service
        super.init(with: router)
    }

    /// Overridden routes for orders service.
    public override func initializeRoutes() {
        add(route: .createOrder) { request, response in
            guard let data: OrderData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let order = try self.service.createOrder(with: data)
            try response.respondJSON(with: order)
        }

        add(route: .getOrder) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidOrderId
            }

            let order = try self.service.getOrder(for: id)
            try response.respondJSON(with: order)
        }

        add(route: .cancelOrder) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidOrderId
            }

            let order = try self.service.getOrder(for: id)
            try response.respondJSON(with: order)
        }

        add(route: .returnOrder) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidOrderId
            }

            guard let data: PickupData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let order = try self.service.returnOrder(for: id, with: data)
            try response.respondJSON(with: order)
        }

        add(route: .updateShipment) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidOrderId
            }

            guard let data: Shipment = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            try self.service.updateShipment(for: id, with: data)
            try response.respondJSON(with: ServiceStatusMessage())
        }

        add(route: .initiateRefund) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidOrderId
            }

            guard let data: RefundData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let order = try self.service.initiateRefund(for: id, with: data)
            try response.respondJSON(with: order)
        }

        add(route: .deleteOrder) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidOrderId
            }

            try self.service.deleteOrder(for: id)
            try response.respondJSON(with: ServiceStatusMessage())
        }
    }
}
