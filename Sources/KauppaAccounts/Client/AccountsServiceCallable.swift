import Foundation

import KauppaAccountsModel

/// General API for the accounts service to be implemented by both the
/// service and the client.
public protocol AccountsServiceCallable {
    /// Create an account with user-supplied information.
    ///
    ///  - parameter data: `AccountData` to be stored.
    ///  - returns: New `Account` from `AccountData` provided.
    func createAccount(withData data: AccountData) throws -> Account

    /// Get an account associated with an ID.
    func getAccount(id: UUID) throws -> Account

    /// Delete an account associated with an ID.
    func deleteAccount(id: UUID) throws -> ()

    /// Update an account with user-supplied patch data.
    func updateAccount(id: UUID, data: AccountPatch) throws -> Account
}
