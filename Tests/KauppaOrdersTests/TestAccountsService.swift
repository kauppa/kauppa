import Foundation
import XCTest

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel

public class TestAccountsService: AccountsServiceCallable {
    var accounts = [UUID: Account]()
    // Orders service doesn't allow placing orders if the account doesn't
    // have any verified mails. Change this flag to mimic it.
    var markAsVerified = true

    public func createAccount(with data: AccountData) throws -> Account {
        let account = Account(with: data)
        accounts[account.id] = account
        return account
    }

    public func getAccount(for id: UUID) throws -> Account {
        guard var account = accounts[id] else {
            throw ServiceError.invalidAccountId
        }

        if markAsVerified {
            var email = Email("foo@bar.com")
            email.isVerified = true
            account.data.emails.insert(email)
        }

        return account
    }

    // NOTE: Not meant to be called by orders
    public func verifyEmail(_ email: String) throws -> () {
        throw ServiceError.invalidAccountEmail
    }

    // NOTE: Not meant to be called by orders
    public func deleteAccount(for id: UUID) throws -> () {
        throw ServiceError.invalidAccountId
    }

    // NOTE: Not meant to be called by orders
    public func updateAccount(for id: UUID, with data: AccountPatch) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    // NOTE: Not meant to be called by orders
    public func addAccountProperty(to id: UUID, using data: AccountPropertyAdditionPatch) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    // NOTE: Not meant to be called by orders
    public func deleteAccountProperty(from id: UUID, using data: AccountPropertyDeletionPatch) throws -> Account {
        throw ServiceError.invalidAccountId
    }
}
