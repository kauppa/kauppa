import KauppaAccountsModel

/// General API for the accounts service to be implemented by both the
/// service and the client.
public protocol AccountsServiceCallable {
    /// Create an account with user-supplied information.
    func createAccount(withData data: AccountData) -> Account?
}
