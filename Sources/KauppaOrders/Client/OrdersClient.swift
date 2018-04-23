import Foundation

import KauppaCore
import KauppaOrdersModel
import KauppaShipmentsModel

/// HTTP client for the orders service.
public class OrdersServiceClient<C: ClientCallable>: ServiceClient<C, OrdersRoutes>, OrdersServiceCallable {
    public func createOrder(with data: OrderData) throws -> Order {
        let client = try createClient(for: .createOrder)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func getOrder(for id: UUID) throws -> Order {
        let client = try createClient(for: .getOrder, with: ["id": id])
        return try requestJSON(with: client)
    }

    public func cancelOrder(for id: UUID) throws -> Order {
        let client = try createClient(for: .cancelOrder, with: ["id": id])
        return try requestJSON(with: client)
    }

    public func returnOrder(for id: UUID, with data: PickupData) throws -> Order {
        let client = try createClient(for: .returnOrder, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func updateShipment(for id: UUID, with data: Shipment) throws -> () {
        let client = try createClient(for: .updateShipment, with: ["id": id])
        try client.setJSON(using: data)
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }

    public func initiateRefund(for id: UUID, with data: RefundData) throws -> Order {
        let client = try createClient(for: .initiateRefund, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func deleteOrder(for id: UUID) throws -> () {
        let client = try createClient(for: .deleteOrder, with: ["id": id])
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }
}
