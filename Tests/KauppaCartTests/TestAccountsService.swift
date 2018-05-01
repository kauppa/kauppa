import Foundation
import XCTest

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel

public class TestAccountsService: AccountsServiceCallable {
    var accounts = [UUID: Account]()

    public func createAccount(with data: Account) throws -> Account {
        accounts[data.id!] = data
        return data
    }

    public func getAccount(for id: UUID) throws -> Account {
        guard let account = accounts[id] else {
            throw ServiceError.invalidAccountId
        }

        return account
    }

    // NOTE: Not meant to be called by cart
    public func verifyEmail(_ email: String) throws -> () {
        throw ServiceError.invalidAccountEmail
    }

    // NOTE: Not meant to be called by cart
    public func deleteAccount(for id: UUID) throws -> () {
        throw ServiceError.invalidAccountId
    }

    // NOTE: Not meant to be called by cart
    public func updateAccount(for id: UUID, with data: AccountPatch) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    // NOTE: Not meant to be called by cart
    public func addAccountProperty(to id: UUID, using data: AccountPropertyAdditionPatch) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    // NOTE: Not meant to be called by cart
    public func deleteAccountProperty(from id: UUID, using data: AccountPropertyDeletionPatch) throws -> Account {
        throw ServiceError.invalidAccountId
    }
}
