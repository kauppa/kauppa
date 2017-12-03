import KauppaOrdersModel

public protocol OrdersPersisting {
    func createNewOrder(orderData: Order)
}
