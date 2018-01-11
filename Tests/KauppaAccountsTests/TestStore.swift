import Foundation

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

    public func createAccount(data: Account) throws -> () {
        createCalled = true
        for email in data.data.emails {
            emails[email.value] = data.id
        }

        accounts[data.id] = data
        return ()
    }

    public func getAccount(id: UUID) throws -> Account {
        getCalled = true
        guard let account = accounts[id] else {
            throw AccountsError.invalidAccount
        }

        return account
    }

    public func getAccount(email: String) throws -> Account {
        guard let id = emails[email] else {
            throw AccountsError.invalidAccount
        }

        return try getAccount(id: id)
    }

    public func deleteAccount(forId id: UUID) throws -> () {
        deleteCalled = true
        if accounts.removeValue(forKey: id) != nil {
            return ()
        } else {
            throw AccountsError.invalidAccount
        }
    }

    public func updateAccount(accountData: Account) throws -> () {
        updateCalled = true
        accounts[accountData.id] = accountData
        return ()
    }
}
