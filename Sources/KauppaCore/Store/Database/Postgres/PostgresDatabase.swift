import NIO
import NIOOpenSSL
import PostgreSQL

/// Async PostgreSQL client implementation.
public class PostgresDatabase: Database {

    public typealias ValueConvertible = PostgreSQLDataConvertible

    public typealias Row = PostgreDatabaseRow

    /// Event loop initialized with the number of CPUs in the machine.
    private var eventLoopGroup = MultiThreadedEventLoopGroup(numThreads: System.coreCount)
    /// Configuration for the database client.
    private let config: PostgreSQLDatabaseConfig
    /// Actual database client used for executing the query.
    private let database: PostgreSQLDatabase

    public required init(for url: URL, with tlsConfig: TLSConfig?) throws {
        if let config = tlsConfig {
            let privateKey = OpenSSLPrivateKeySource.file(config.clientPrivateKeyPath)
            let rootCert = OpenSSLTrustRoots.file(config.authorityCertificatePath)
            let clientCert = OpenSSLCertificateSource.file(config.clientCertificatePath)
            let tlsConfig = TLSConfiguration.forClient(certificateVerification: .fullVerification,
                                                       trustRoots: rootCert,
                                                       certificateChain: [clientCert],
                                                       privateKey: privateKey)
            let transportConfig = PostgreSQLTransportConfig.customTLS(tlsConfig)
            self.config = try PostgreSQLDatabaseConfig(url: url.absoluteString, transport: transportConfig)
        } else {
            self.config = try PostgreSQLDatabaseConfig(url: url.absoluteString)
        }

        database = PostgreSQLDatabase(config: self.config)
    }

    public func execute(query: String, with parameters: [ValueConvertible]) throws -> [Row] {
        let future = database.newConnection(on: eventLoopGroup).then() { connection in
            return connection.query(query, parameters)
        }

        do {
            return try future.wait()    // drive the future to completion
        } catch let err {
            // FIXME: Log error
            throw ServiceError.errorExecutingQuery
        }
    }
}
