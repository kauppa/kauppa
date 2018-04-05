import Foundation

import KauppaCore
import KauppaAccountsModel

/// Methods that mutate the underlying store with information.
public protocol AccountsPersisting: Persisting {
    /// Create account with the given data.
    func createAccount(with data: Account) throws -> ()

    /// Delete an account associated with an ID.
    func deleteAccount(for: UUID) throws -> ()

    /// Update an account associated with an ID.
    func updateAccount(with data: Account) throws -> ()
}
