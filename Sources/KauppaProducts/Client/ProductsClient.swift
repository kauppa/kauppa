import Foundation

import KauppaCore

public class ProductsClient<C: ClientCallable> {
    private let endpoint: URL

    public init?(for endpoint: String) {
        if let url = URL(string: endpoint, relativeTo: nil) {
            self.endpoint = url
        } else {
            return nil
        }
    }
}

// extension ProductsClient<C: ClientCallable>: ProductsServiceCallable {
//     // TODO: Do something about `Address`

//     func createProduct(with data: ProductData, from address: Address?) throws -> Product {
//         let endpoint = URL(ProductRoutes.createProduct, relativeTo: self.endpoint)

//     }
// }
