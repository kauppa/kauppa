import Foundation

import KauppaCore
import KauppaAccountsModel

/// Methods that fetch data from the underlying store.
public protocol AccountsQuerying: Querying {
    /// Get the account data for the given email.
    ///
    /// - Parameters:
    ///   - for: The email associated with the account (as a string).
    /// - Throws: `AccountsError` on failure.
    func getAccount(for email: String) throws -> Account

    /// Get the account data for the given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    /// - Throws: `AccountsError` on failure.
    func getAccount(for id: UUID) throws -> Account
}
