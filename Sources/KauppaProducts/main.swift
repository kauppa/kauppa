import Foundation

import Kitura

import KauppaCore
import KauppaProductsModel
import KauppaProductsRepository
import KauppaProductsService
import KauppaProductsStore
import KauppaTaxClient


class NoOpStore: ProductsStorable {

    public func createNewProduct(with data: Product) throws -> () {}

    public func getProduct(for id: UUID) throws -> Product {
        throw ServiceError.invalidProductId
    }

    public func deleteProduct(for id: UUID) throws -> () {}

    public func updateProduct(with data: Product) throws -> () {}

    public func createNewCollection(with data: ProductCollection) throws -> () {}

    public func getCollection(for id: UUID) throws -> ProductCollection {
        throw ServiceError.invalidCollectionId
    }

    public func updateCollection(with data: ProductCollection) throws -> () {}

    public func deleteCollection(for id: UUID) throws -> () {}

    public func createAttribute(with data: Attribute) throws -> () {}

    public func getAttribute(for id: UUID) throws -> Attribute {
        throw ServiceError.invalidAttributeId
    }

    public func createCategory(with data: Category) throws -> () {}

    public func getCategory(for id: UUID) throws -> Category {
        throw ServiceError.invalidCategoryId
    }

    public func getCategory(for name: String) throws -> Category {
        throw ServiceError.invalidCategoryName
    }

    public func getCategories() throws -> [Category] {
        return []
    }
}


let repository = ProductsRepository(with: NoOpStore())
let taxEndpoint = String.from(environment: "KAUPPA_TAX_ENDPOINT")!
let taxClient: TaxServiceClient<SwiftyRestRequest> = TaxServiceClient(for: taxEndpoint)!
let productsService = ProductsService(with: repository, taxService: taxClient)

let router = Router()       // Kitura's router
let serviceRouter = ProductsRouter(with: router, service: productsService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
