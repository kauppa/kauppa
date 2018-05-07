import Foundation

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

    public func getData() -> Data? {
        var data = Data()
        let result = try? self.read(into: &data)
        return result != nil ? data : nil
    }
}
