import Foundation

import KauppaCore
import KauppaAccountsClient
import KauppaAccountsModel
import KauppaAccountsRepository

/// AccountsService provides a public API for accounts actions.
public class AccountsService {
    let repository: AccountsRepository

    /// Initializes a new instance of `AccountsService` with a repository.
    ///
    /// - Parameters:
    ///   - with: The `AccountsRepository` to be used by the service.
    public init(with repository: AccountsRepository) {
        self.repository = repository
    }
}

// NOTE: See the actual protocol in `KauppaAccountsClient` for exact usage.
extension AccountsService: AccountsServiceCallable {
    public func createAccount(with data: Account) throws -> Account {
        var account = data
        try account.validate()

        for email in account.emails {
            if let _ = try? repository.getAccount(for: email.value) {
                throw ServiceError.accountExists
            }
        }

        let date = Date()
        account.id = UUID()
        account.createdOn = date
        account.updatedAt = date

        return try repository.createAccount(with: account)
    }

    public func getAccount(for id: UUID) throws -> Account {
        return try repository.getAccount(for: id)
    }

    public func deleteAccount(for id: UUID) throws -> () {
        return try repository.deleteAccount(for: id)
    }

    public func verifyEmail(_ email: String) throws {
        var account = try repository.getAccount(for: email)

        account.emails.mutateOnce(matching: { $0.value == email }, with: { email in
            email.isVerified = true
        })

        let _ = try repository.updateAccount(for: account.id!, with: account)
    }

    public func updateAccount(for id: UUID, with data: AccountPatch) throws -> Account {
        var accountData = try repository.getAccount(for: id)

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
        return try repository.updateAccount(for: id, with: accountData)
    }

    public func addAccountProperty(to id: UUID, using data: AccountPropertyAdditionPatch) throws -> Account {
        var accountData = try repository.getAccount(for: id)

        if let address = data.address {
            if accountData.address == nil {
                accountData.address = []
            }

            accountData.address!.append(address)
        }

        if let number = data.phone {
            if accountData.phoneNumbers == nil {
                accountData.phoneNumbers = ArraySet()
            }

            accountData.phoneNumbers!.insert(number)
        }

        if let email = data.email {
            accountData.emails.insert(email)
        }

        try accountData.validate()
        return try repository.updateAccount(for: id, with: accountData)
    }

    public func deleteAccountProperty(from id: UUID, using data: AccountPropertyDeletionPatch) throws -> Account {
        var accountData = try repository.getAccount(for: id)

        if let index = data.removeEmailAt {
            // If this is the last email, then disallow this operation.
            if accountData.emails.count == 1 {
                throw ServiceError.accountEmailRequired
            }

            accountData.emails.remove(at: index)
        }

        if let index = data.removePhoneAt {
            if accountData.phoneNumbers != nil {
                accountData.phoneNumbers!.remove(at: index)
            }
        }

        if let index = data.removeAddressAt {
            if accountData.address != nil && accountData.address!.count > 0 {
                accountData.address!.remove(at: index)
            }
        }

        return try repository.updateAccount(for: id, with: accountData)
    }
}
