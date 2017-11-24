import KauppaAccountsModel
import KauppaAccountsRepository

/// AccountsService provides a public API for accounts
/// actions.
public class AccountsService {

    let depositing: AccountsDepositing?

    /// Initializes new `AccountsService` instance with
    /// a depositing-compliant object.
    public init(withDepositing depositing: AccountsDepositing) {
        self.depositing = depositing
    }

    /// Creates a new `Account` and registers it with the store.
    ///
    ///  - parameter data: `AccountData` to be stored.
    ///  - returns: New `Account` from `AccountData` provided.
    public func createAccount(withData data: AccountData) -> Account? {
        return nil
    }
}
