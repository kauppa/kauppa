import Foundation

@testable import KauppaShipmentsModel
@testable import KauppaShipmentsStore

public class TestStore: ShipmentsStorable {
    public var shipments = [UUID: Shipment]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var updateCalled = false
    public var getCalled = false

    public func createShipment(with data: Shipment) throws -> () {
        createCalled = true
        shipments[data.id] = data
    }

    public func updateShipment(with data: Shipment) throws -> () {
        updateCalled = true
        let _ = try getShipment(for: data.id)
        shipments[data.id] = data
    }

    public func getShipment(for id: UUID) throws -> Shipment {
        getCalled = true
        guard let data = shipments[id] else {
            throw ShipmentsError.invalidShipment
        }

        return data
    }
}
