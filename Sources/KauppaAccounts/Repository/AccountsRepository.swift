import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsStore

// Manages the retrievable and persistance of accounts data
// inline with the business logic requirements.
public class AccountsRepository {
    // FIXME: To avoid running out of memory, we should clean the
    // least recently used items every now and then.
    var emails = [String: UUID]()
    var accounts = [UUID: Account]()
    var store: AccountsStorable

    /// Initialize an instance of `AccountsRepository` with an account store.
    ///
    /// - Parameters:
    ///   - with: Anything that implements `AccountsStorable`
    public init(with store: AccountsStorable) {
        self.store = store
    }

    /// Get the account for a given ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    /// - Returns: `Account` (if it exists) in the repository or store.
    /// - Throws: `ServiceError` on failure.
    public func getAccount(for id: UUID) throws -> Account {
        guard let account = accounts[id] else {
            let account = try store.getAccount(for: id)
            accounts[id] = account
            return account
        }

        return account
    }

    /// Get the account corresponding to a given email.
    ///
    /// - Parameters:
    ///   - for: The email of the account as a string.
    /// - Returns: `Account` (if it exists) in the repository or store.
    /// - Throws: `ServiceError` on failure.
    public func getAccount(for email: String) throws -> Account {
        guard let id = emails[email] else {
            let account = try store.getAccount(for: email)
            emails[email] = account.id
            return account
        }

        return try getAccount(for: id)
    }

    /// Get the account data corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    /// - Returns: `AccountData` for the `Account` (if it exists) in the repository or store.
    /// - Throws: `ServiceError` on failure.
    public func getAccountData(for id: UUID) throws -> AccountData {
        let account = try getAccount(for: id)
        return account.data
    }

    /// Create an account with data from the service.
    ///
    /// - Parameters:
    ///   - with: The `AccountData` for this account
    /// - Returns: The created `Account`
    /// - Throws: `ServiceError` if there were errors.
    public func createAccount(with data: AccountData) throws -> Account {
        let account = Account(with: data)
        for email in data.emails {
            emails[email.value] = account.id
        }

        accounts[account.id] = account
        try store.createAccount(with: account)
        return account
    }

    /// Delete an account corresponding to an ID.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    /// - Throws: `ServiceError` on failure.
    public func deleteAccount(for id: UUID) throws -> () {
        accounts.removeValue(forKey: id)
        try store.deleteAccount(for: id)
    }

    /// Update an account with patch data from the service.
    ///
    /// - Parameters:
    ///   - for: The `UUID` of the account.
    ///   - with: The updated `AccountData`
    /// - Returns: The `Account` containing the updated data.
    /// - Throws: `ServiceError` on failure.
    public func updateAccount(for id: UUID, with data: AccountData) throws -> Account {
        var account = try getAccount(for: id)
        let date = Date()
        account.updatedAt = date
        account.data = data
        accounts[id] = account
        try store.updateAccount(with: account)
        return account
    }
}
