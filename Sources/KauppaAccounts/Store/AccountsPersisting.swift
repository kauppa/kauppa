import Foundation

import KauppaCore
import KauppaAccountsModel

// AccountsStorable manages the persistant storage
// and retrieving of accounts information to and
// from a stateful data store.
public protocol AccountsPersisting: Persisting {
    /// Create account with the given data.
    func createAccount(data: Account) throws -> ()

    /// Delete an account associated with an ID.
    func deleteAccount(forId: UUID) throws -> ()

    /// Update an account associated with an ID.
    func updateAccount(accountData: Account) throws -> ()
}
