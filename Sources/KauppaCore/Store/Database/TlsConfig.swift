
/// (Client) TLS configuration for a database.
public struct TlsConfig {
    /// CA certificate to be used for verifying the server's certificate.
    public let authorityCertificatePath: String
    /// Private key of the client.
    public let clientPrivateKeyPath: String
    /// Certificate this client has to offer the server.
    public let clientCertificatePath: String
}
