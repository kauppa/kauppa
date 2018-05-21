import NIO
import NIOOpenSSL
import PostgreSQL
import SwiftKuery

/// Async PostgreSQL client implementation.
public class PostgresDatabase: Database {

    public typealias ValueConvertible = PostgreSQLDataConvertible

    public typealias Row = PostgreDatabaseRow

    /// Query builder specific to PostgreSQL.
    public private(set) var queryBuilder: QueryBuilder

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

        // Query builder from https://github.com/IBM-Swift/Swift-Kuery-PostgreSQL/blob/337499d196e92b361a24545313a585d4b57a374c/Sources/SwiftKueryPostgreSQL/PostgreSQLConnection.swift

        queryBuilder = QueryBuilder(withDeleteRequiresUsing: true,
                                    withUpdateRequiresFrom: true,
                                    createAutoIncrement: PostgresDatabase.createAutoIncrement)
        queryBuilder.updateSubstitutions([
            QueryBuilder.QuerySubstitutionNames.ucase : "UPPER",
            QueryBuilder.QuerySubstitutionNames.lcase : "LOWER",
            QueryBuilder.QuerySubstitutionNames.len : "LENGTH",
            QueryBuilder.QuerySubstitutionNames.numberedParameter : "$",
            QueryBuilder.QuerySubstitutionNames.namedParameter : "",
            QueryBuilder.QuerySubstitutionNames.double : "double precision",
            QueryBuilder.QuerySubstitutionNames.uuid : "uuid"
        ])

        database = PostgreSQLDatabase(config: self.config)
    }

    public func execute(query: String, with parameters: [ValueConvertible]) throws -> [Row] {
        let future = database.newConnection(on: eventLoopGroup).then() { connection in
            return connection.query(query, parameters)
        }

        do {
            return try future.wait()    // drive the future to completion
        } catch {
            // FIXME: Log error
            throw ServiceError.errorExecutingQuery
        }
    }

    private static func createAutoIncrement(_ type: String) -> String {
        switch type {
            case "smallint":
                return "smallserial"
            case "integer":
                return "serial"
            case "bigint":
                return "bigserial"
            default:
                return ""
        }
    }
}
