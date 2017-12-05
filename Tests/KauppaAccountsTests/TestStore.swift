import Foundation

@testable import KauppaAccountsModel
@testable import KauppaAccountsStore

public class TestStore: AccountsStorable {
    public var emails = [String: UUID]()
    public var accounts = [UUID: Account]()

    // Variables to indicate the count of function calls
    public var createCalled = false
    public var getCalled = false

    public func createAccount(data: Account) throws -> () {
        createCalled = true
        emails[data.data.email] = data.id
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
}
