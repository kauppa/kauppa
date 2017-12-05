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
    public func getAccount(id: UUID) throws -> Account {
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

        return try getAccount(id: id)
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
}
