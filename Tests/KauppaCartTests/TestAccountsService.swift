import Foundation
import XCTest

import KauppaAccountsClient
import KauppaAccountsModel

public class TestAccountsService: AccountsServiceCallable {
    var accounts = [UUID: Account]()

    public func createAccount(withData data: AccountData) throws -> Account {
        let id = UUID()
        let date = Date()
        accounts[id] = Account(id: id, createdOn: date, updatedAt: date, data: data)
        return accounts[id]!
    }

    public func getAccount(id: UUID) throws -> Account {
        guard let account = accounts[id] else {
            throw AccountsError.invalidAccount
        }

        return account
    }

    // NOTE: Not meant to be called by cart
    public func deleteAccount(id: UUID) throws -> () {
        throw AccountsError.invalidAccount
    }

    // NOTE: Not meant to be called by cart
    public func updateAccount(id: UUID, data: AccountPatch) throws -> Account {
        throw AccountsError.invalidAccount
    }

    // NOTE: Not meant to be called by cart
    public func addAccountProperty(id: UUID, data: AccountPropertyAdditionPatch) throws -> Account {
        throw AccountsError.invalidAccount
    }

    // NOTE: Not meant to be called by cart
    public func deleteAccountProperty(id: UUID, data: AccountPropertyDeletionPatch) throws -> Account {
        throw AccountsError.invalidAccount
    }
}
