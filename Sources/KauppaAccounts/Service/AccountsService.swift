import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel
import KauppaAccountsRepository

/// AccountsService provides a public API for accounts actions.
public class AccountsService {
    let repository: AccountsRepository

    /// Initializes new `AccountsService` instance with
    /// a depositing-compliant object.
    public init(withRepository repository: AccountsRepository) {
        self.repository = repository
    }
}

// NOTE: See the actual protocol in `KauppaAccountsClient` for exact usage.
extension AccountsService: AccountsServiceCallable {
    public func createAccount(withData data: AccountData) throws -> Account {
        try data.validate()
        for email in data.emails {
            if let _ = try? repository.getAccount(forEmail: email.value) {
                throw AccountsError.accountExists
            }
        }

        return try repository.createAccount(data: data)
    }

    public func getAccount(id: UUID) throws -> Account {
        return try repository.getAccount(forId: id)
    }

    public func deleteAccount(id: UUID) throws -> () {
        return try repository.deleteAccount(forId: id)
    }

    public func verifyEmail(_ email: String) throws {
        let account = try repository.getAccount(forEmail: email)
        var accountData = account.data

        accountData.emails.mutateOnce(matching: { $0.value == email }, with: { email in
            email.isVerified = true
        })

        let _ = try repository.updateAccountData(forId: account.id, data: accountData)
    }

    public func updateAccount(id: UUID, data: AccountPatch) throws -> Account {
        var accountData = try repository.getAccountData(forId: id)

        if let name = data.name {
            accountData.name = name
        }

        if let numbers = data.phoneNumbers {
            accountData.phoneNumbers = numbers
        }

        if let emails = data.emails {
            accountData.emails = emails
        }

        if let addressList = data.address {
            accountData.address = addressList
        }

        try accountData.validate()
        return try repository.updateAccountData(forId: id, data: accountData)
    }

    public func addAccountProperty(id: UUID, data: AccountPropertyAdditionPatch) throws -> Account {
        var accountData = try repository.getAccountData(forId: id)

        if let address = data.address {
            accountData.address.insert(address)
        }

        if let number = data.phone {
            accountData.phoneNumbers.insert(number)
        }

        if let email = data.email {
            accountData.emails.insert(email)
        }

        try accountData.validate()
        return try repository.updateAccountData(forId: id, data: accountData)
    }

    public func deleteAccountProperty(id: UUID, data: AccountPropertyDeletionPatch) throws -> Account {
        var accountData = try repository.getAccountData(forId: id)

        if let index = data.removeEmailAt {
            accountData.emails.remove(at: index)
            if accountData.emails.isEmpty {         // if there are no more emails, disallow this
                throw AccountsError.emailRequired
            }
        }

        if let index = data.removePhoneAt {
            accountData.phoneNumbers.remove(at: index)
        }

        if let index = data.removeAddressAt {
            accountData.address.remove(at: index)
        }

        return try repository.updateAccountData(forId: id, data: accountData)
    }
}
