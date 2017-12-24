import Foundation

@testable import KauppaShipmentsModel
@testable import KauppaShipmentsStore

public class TestStore: ShipmentsStorable {
    public var shipments = [UUID: Shipment]()

    // Variables to indicate the count of function calls
    public var createCalled = false

    public func createShipment(data: Shipment) throws -> () {
        createCalled = true
        shipments[data.id] = data
        return ()
    }
}
