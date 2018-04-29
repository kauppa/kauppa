import Foundation

import KauppaCore
import KauppaAccountsModel

/// A no-op store for accounts which doesn't support data persistence/querying.
/// This way, the repository takes care of all service requests by providing
/// in-memory data.
public class AccountsNoOpStore: AccountsStorable {
    public init() {}

    public func createAccount(with data: Account) throws -> () {}

    public func getAccount(for id: UUID) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    public func getAccount(for email: String) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    public func deleteAccount(for id: UUID) throws -> () {}

    public func updateAccount(with data: Account) throws -> () {}
}
