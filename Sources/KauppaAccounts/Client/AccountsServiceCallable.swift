import Foundation

import KauppaAccountsModel

/// General API for the accounts service to be implemented by both the
/// service and the client.
public protocol AccountsServiceCallable {
    /// Create an account with user-supplied information.
    ///
    /// - Parameters:
    ///   - withData: `AccountData` required for creating an account.
    /// - Returns: A validated `Account`
    /// - Throws: `AccountsError`
    func createAccount(withData data: AccountData) throws -> Account

    /// Get an account associated with an ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the account.
    /// - Returns: The `Account` (if it exists)
    /// - Throws: `AccountsError` (if it's non-existent)
    func getAccount(id: UUID) throws -> Account

    /// Delete an account associated with an ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the account.
    /// - Throws: `AccountsError` (if the account doesn't exist)
    func deleteAccount(id: UUID) throws -> ()

    /// Update an account with user-supplied patch data.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the account.
    ///   - data: The `AccountPatch` data required for updating an account.
    /// - Returns: The `Account` (if it's been updated successfully)
    /// - Throws: `AccountsError`
    func updateAccount(id: UUID, data: AccountPatch) throws -> Account

    /// Adds one or more items to the corresponding collection fields in an user account.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the account.
    ///   - data: The `AccountPropertyAdditionPatch` data required for adding
    ///     individual properties.
    /// - Returns: The `Account` (if it's been updated successfully)
    /// - Throws: `AccountsError`
    func addAccountProperty(id: UUID, data: AccountPropertyAdditionPatch) throws -> Account

    /// Reset individual account properties with the given patch.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the account.
    ///   - data: The `AccountPropertyDeletionPatch` data required for removing
    ///     individual properties.
    /// - Returns: The `Account` (if it's been updated successfully)
    /// - Throws: `AccountsError`
    func deleteAccountProperty(id: UUID, data: AccountPropertyDeletionPatch) throws -> Account
}
