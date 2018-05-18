import NIO
import NIOOpenSSL
import PostgreSQL

public class PostgresDatabase: Database {

    private var eventLoopGroup = MultiThreadedEventLoopGroup(numThreads: System.coreCount)

    private var config: PostgreSQLDatabaseConfig? = nil

    private var inner: PostgreSQLDatabase? = nil

    internal override func initDatabase() throws {
        if let config = self.tlsConfig {
            let privateKey = OpenSSLPrivateKeySource.file(config.clientPrivateKeyPath)
            let rootCert = OpenSSLTrustRoots.file(config.authorityCertificatePath)
            let clientCert = OpenSSLCertificateSource.file(config.clientCertificatePath)
            let tlsConfig = TLSConfiguration.forClient(certificateVerification: .fullVerification,
                                                       trustRoots: rootCert,
                                                       certificateChain: [clientCert],
                                                       privateKey: privateKey)
            let transportConfig = PostgreSQLTransportConfig.customTLS(tlsConfig)
            self.config = try PostgreSQLDatabaseConfig(url: url, transport: transportConfig)
        } else {
            self.config = try PostgreSQLDatabaseConfig(url: url)
        }

        self.inner = PostgreSQLDatabase(config: self.config!)
    }
}
