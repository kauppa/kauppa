import Foundation

import KauppaCore
import KauppaAccountsModel

/// Methods that fetch data from the underlying store.
public protocol AccountsQuerying: Querying {
    /// Get the account data for the given email.
    func getAccount(for email: String) throws -> Account

    /// Get the account data for the given ID.
    func getAccount(for id: UUID) throws -> Account
}
