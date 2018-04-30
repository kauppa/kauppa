import Foundation

import KauppaCore
import KauppaAccountsModel

/// Methods that mutate the underlying store with information.
public protocol AccountsPersisting: Persisting {
    /// Create account with the given data.
    ///
    /// - Parameters:
    ///   - with: The `Account` from repository.
    /// - Throws: `ServiceError` on failure.
    func createAccount(with data: Account) throws -> ()

    /// Delete an account associated with an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    /// - Throws: `ServiceError` on failure.
    func deleteAccount(for: UUID) throws -> ()

    /// Update an account associated with an ID.
    ///
    /// - Parameters:
    ///   - with: The updated `Account` from repository.
    /// - Throws: `ServiceError` on failure.
    func updateAccount(with data: Account) throws -> ()
}
