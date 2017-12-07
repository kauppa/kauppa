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

    public init(withStore store: AccountsStorable) {
        self.store = store
    }

    /// Get the account for a given ID.
    public func getAccount(forId id: UUID) throws -> Account {
        guard let account = accounts[id] else {
            let account = try store.getAccount(id: id)
            accounts[id] = account
            return account
        }

        return account
    }

    /// Get the account corresponding to a given email.
    public func getAccount(forEmail email: String) throws -> Account {
        guard let id = emails[email] else {
            let account = try store.getAccount(email: email)
            emails[email] = account.id
            return account
        }

        return try getAccount(forId: id)
    }

    /// Get the account data corresponding to an ID.
    public func getAccountData(forId id: UUID) throws -> AccountData {
        let account = try getAccount(forId: id)
        return account.data
    }

    /// Create an account with data from the service.
    public func createAccount(data: AccountData) throws -> Account {
        let id = UUID()
        let date = Date()
        let account = Account(id: id, createdOn: date,
                              updatedAt: date, data: data)
        emails[data.email] = id
        accounts[id] = account
        try store.createAccount(data: account)
        return account
    }

    /// Delete an account corresponding to an ID.
    public func deleteAccount(forId id: UUID) throws -> () {
        accounts.removeValue(forKey: id)
        try store.deleteAccount(forId: id)
    }

    /// Update an account with patch data from the service.
    public func updateAccountData(forId id: UUID, data: AccountData) throws -> Account {
        var account = try getAccount(forId: id)
        let date = Date()
        account.updatedAt = date
        account.data = data
        accounts[id] = account
        try store.updateAccount(accountData: account)
        return account
    }
}
