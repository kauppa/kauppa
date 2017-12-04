import Foundation

import KauppaOrdersModel

public protocol OrdersPersisting {
    func createNewOrder(orderData: Order) throws -> ()

    func deleteOrder(id: UUID) throws -> ()
}
