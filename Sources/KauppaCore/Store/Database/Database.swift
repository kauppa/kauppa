import Foundation

/// Parent class to be used for all database classes.
open class Database {

    let url: String

    let tlsConfig: TlsConfig?

    public init(for url: String, with tlsConfig: TlsConfig? = nil,
                async: Bool = true) throws
    {
        if URL(string: url) == nil {
            throw ServiceError.invalidDatabaseURL
        }

        self.url = url
        self.tlsConfig = tlsConfig

        do {
            try self.initDatabase()
        } catch let err as ServiceError {
            throw err
        } catch {
            throw ServiceError.unknownError
        }
    }

    /// Overridable method for databases to initialize their own properties.
    /// This is called immediately after initializing this class.
    internal func initDatabase() throws {}
}
