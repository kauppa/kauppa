import Foundation

import KauppaAccountsModel

/// General API for the accounts service to be implemented by both the
/// service and the client.
public protocol AccountsServiceCallable {
    /// Create an account with user-supplied information.
    ///
    /// - Parameters:
    ///   - with: `AccountData` required for creating an account.
    /// - Returns: A validated `Account`
    /// - Throws: `AccountsError`
    func createAccount(with data: AccountData) throws -> Account

    /// This notifies the service that an email has been verified.
    /// It gets the associated account, sets the `isVerified` flag
    /// and returns the account.
    ///
    /// - Parameters:
    ///   - email: Email to be verified.
    /// - Throws: `AccountsError` if the email doesn't exist.
    func verifyEmail(_ email: String) throws -> ()

    /// Get an account associated with an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    /// - Returns: The `Account` (if it exists)
    /// - Throws: `AccountsError` (if it's non-existent)
    func getAccount(for id: UUID) throws -> Account

    /// Delete an account associated with an ID.
    ///
    /// - Parameters:
    ///   - id: The `UUID` of the account.
    /// - Throws: `AccountsError` (if the account doesn't exist)
    func deleteAccount(for id: UUID) throws -> ()

    /// Update an account with user-supplied patch data.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    ///   - with: The `AccountPatch` data required for updating an account.
    /// - Returns: The `Account` (if it's been updated successfully)
    /// - Throws: `AccountsError`
    func updateAccount(for id: UUID, with data: AccountPatch) throws -> Account

    /// Adds one or more items to the corresponding collection fields in an user account.
    ///
    /// - Parameters:
    ///   - to: The `UUID` of the account.
    ///   - using: The `AccountPropertyAdditionPatch` data required for adding
    ///     individual properties.
    /// - Returns: The `Account` (if it's been updated successfully)
    /// - Throws: `AccountsError`
    func addAccountProperty(to id: UUID, using data: AccountPropertyAdditionPatch) throws -> Account

    /// Reset individual account properties with the given patch.
    ///
    /// - Parameters:
    ///   - from: The `UUID` of the account.
    ///   - using: The `AccountPropertyDeletionPatch` data required for removing
    ///     individual properties.
    /// - Returns: The `Account` (if it's been updated successfully)
    /// - Throws: `AccountsError`
    func deleteAccountProperty(from id: UUID, using data: AccountPropertyDeletionPatch) throws -> Account
}
