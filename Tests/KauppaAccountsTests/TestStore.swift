import Foundation

import KauppaCore
@testable import KauppaAccountsModel
@testable import KauppaAccountsStore

public class TestStore: AccountsStorable {
    public var emails = [String: UUID]()
    public var accounts = [UUID: Account]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false
    public var deleteCalled = false
    public var updateCalled = false

    public func createAccount(with data: Account) throws -> () {
        createCalled = true
        for email in data.data.emails {
            emails[email.value] = data.id
        }

        accounts[data.id] = data
    }

    public func getAccount(for id: UUID) throws -> Account {
        getCalled = true
        guard let account = accounts[id] else {
            throw ServiceError.invalidAccountId
        }

        return account
    }

    public func getAccount(for email: String) throws -> Account {
        guard let id = emails[email] else {
            throw ServiceError.invalidAccountId
        }

        return try getAccount(for: id)
    }

    public func deleteAccount(for id: UUID) throws -> () {
        deleteCalled = true
        if accounts.removeValue(forKey: id) != nil {
            return
        } else {
            throw ServiceError.invalidAccountId
        }
    }

    public func updateAccount(with data: Account) throws -> () {
        updateCalled = true
        accounts[data.id] = data
    }
}
