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

    public init(with store: AccountsStorable) {
        self.store = store
    }

    /// Get the account for a given ID.
    public func getAccount(for id: UUID) throws -> Account {
        guard let account = accounts[id] else {
            let account = try store.getAccount(for: id)
            accounts[id] = account
            return account
        }

        return account
    }

    /// Get the account corresponding to a given email.
    public func getAccount(for email: String) throws -> Account {
        guard let id = emails[email] else {
            let account = try store.getAccount(for: email)
            emails[email] = account.id
            return account
        }

        return try getAccount(for: id)
    }

    /// Get the account data corresponding to an ID.
    public func getAccountData(for id: UUID) throws -> AccountData {
        let account = try getAccount(for: id)
        return account.data
    }

    /// Create an account with data from the service.
    public func createAccount(with data: AccountData) throws -> Account {
        let id = UUID()
        let date = Date()
        let account = Account(id: id, createdOn: date, updatedAt: date, data: data)
        for email in data.emails {
            emails[email.value] = id
        }

        accounts[id] = account
        try store.createAccount(with: account)
        return account
    }

    /// Delete an account corresponding to an ID.
    public func deleteAccount(for id: UUID) throws -> () {
        accounts.removeValue(forKey: id)
        try store.deleteAccount(for: id)
    }

    /// Update an account with patch data from the service.
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
