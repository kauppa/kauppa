import Kitura

extension RouterRequest: ServiceRequest {
    public func getJson<T: Mappable>() throws -> T {
        return try self.read(as: T.self)
    }
}
