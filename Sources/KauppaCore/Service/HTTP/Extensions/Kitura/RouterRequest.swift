import Kitura

extension RouterRequest: ServiceRequest {
    public func getHeader(for key: String) -> String? {
        return self.headers[key]
    }

    public func getParameter<T: StringParsable>(for key: String) -> T? {
        guard let value = parameters[key] else {
            return nil
        }

        return value.parse()
    }

    public func getJSON<T: Mappable>() throws -> T {
        return try self.read(as: T.self)
    }
}
