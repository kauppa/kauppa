import KauppaOrdersClient
import KauppaOrdersModel
import KauppaOrdersRepository
import KauppaProductsClient

/// Orders service
public class OrdersService: OrdersServiceCallable {
    let repository: OrdersRepository

    let productsService: ProductsServiceCallable

    public init(withRepository repository: OrdersRepository,
                productsService: ProductsServiceCallable)
    {
        self.repository = repository
        self.productsService = productsService
    }

    public func createOrder(data: OrderData) -> Order? {
        return nil
    }
}
