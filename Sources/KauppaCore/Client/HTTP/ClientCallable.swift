import Foundation

public protocol ClientCallable {

    associatedtype Response: ClientResponse

    init(with method: HTTPMethod, on url: URL)

    func setHeader(key: String, value: String)

    func setData(_ data: Data)

    func requestRaw(_ handler: @escaping (Response) -> Void)
}

extension ClientCallable {
    public func setBody(using data: Data) {
        self.setHeader(key: "Content-Length", value: String(format: "%d", data.count))
        self.setData(data)
    }

    public func setJSON<D: Mappable>(using data: D) throws {
        do {
            let jsonData = try JSONEncoder().encode(data)
            self.setBody(using: jsonData)
            self.setHeader(key: "Content-Type", value: "application/json")
        } catch {
            throw ServiceError.jsonSerialization
        }
    }
}
