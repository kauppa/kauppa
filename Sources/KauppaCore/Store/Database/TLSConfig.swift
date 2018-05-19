
/// TLS configuration for a database client.
public struct TLSConfig {
    /// CA certificate to be used for verifying the server's certificate.
    public let authorityCertificatePath: String
    /// Private key of the client.
    public let clientPrivateKeyPath: String
    /// Certificate this client has to offer the server.
    public let clientCertificatePath: String

    public init(caCertPath: String, clientKeyPath: String, clientCertPath: String) {
        authorityCertificatePath = caCertPath
        clientPrivateKeyPath = clientKeyPath
        clientCertificatePath = clientCertPath
    }
}
