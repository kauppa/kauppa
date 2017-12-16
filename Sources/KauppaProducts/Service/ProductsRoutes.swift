import KauppaCore

public struct ProductsRoutes {
    static let globalProducts = "/products"
    static let singleProduct  = "/products/:id"

    static let createProduct          = Route(uri: globalProducts, method: .Post)
    static let getProduct             = Route(uri: singleProduct,  method: .Get)
    static let deleteProduct          = Route(uri: singleProduct,  method: .Delete)
    static let updateProduct          = Route(uri: singleProduct,  method: .Put)
    static let addProductProperty     = Route(uri: singleProduct,  method: .Post)
    static let deleteProductProperty  = Route(uri: singleProduct,  method: .Delete)
}
