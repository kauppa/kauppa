import Foundation

import KauppaCore
import KauppaAccountsModel

/// Methods that mutate the underlying store with information.
public protocol AccountsQuerying: Querying {
    /// Get the account data for the given email.
    func getAccount(email: String) throws -> Account

    /// Get the account data for the given ID.
    func getAccount(id: UUID) throws -> Account
}
