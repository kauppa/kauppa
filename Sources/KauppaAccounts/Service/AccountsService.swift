import KauppaCore
import KauppaAccountsModel
import KauppaAccountsRepository

/// AccountsService provides a public API for accounts actions.
public class AccountsService {
    let repository: AccountsRepository

    /// Initializes new `AccountsService` instance with
    /// a depositing-compliant object.
    public init(withRepository repository: AccountsRepository) {
        self.repository = repository
    }

    /// Creates a new `Account` and registers it with the store.
    ///
    ///  - parameter data: `AccountData` to be stored.
    ///  - returns: New `Account` from `AccountData` provided.
    public func createAccount(withData data: AccountData) throws -> Account {
        if !isValidEmail(data.email) {
            throw AccountsError.invalidEmail
        }

        if let _ = try? repository.getAccount(forEmail: data.email) {
            throw AccountsError.accountExists
        }

        return try repository.createAccount(data: data)
    }
}
