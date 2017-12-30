import Foundation

@testable import KauppaShipmentsModel
@testable import KauppaShipmentsStore

public class TestStore: ShipmentsStorable {
    public var shipments = [UUID: Shipment]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var updateCalled = false
    public var getCalled = false

    public func createShipment(data: Shipment) throws -> () {
        createCalled = true
        shipments[data.id] = data
        return ()
    }

    public func updateShipment(data: Shipment) throws -> () {
        updateCalled = true
        let _ = try getShipment(id: data.id)
        shipments[data.id] = data
        return ()
    }

    public func getShipment(id: UUID) throws -> Shipment {
        getCalled = true
        guard let data = shipments[id] else {
            throw ShipmentsError.invalidShipment
        }

        return data
    }
}
