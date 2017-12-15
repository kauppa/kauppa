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

extension AccountsService: AccountsServiceCallable {
    public func createAccount(withData data: AccountData) throws -> Account {
        try data.validate()
        if let _ = try? repository.getAccount(forEmail: data.email) {
            throw AccountsError.accountExists
        }

        return try repository.createAccount(data: data)
    }

    public func getAccount(id: UUID) throws -> Account {
        return try repository.getAccount(forId: id)
    }

    public func deleteAccount(id: UUID) throws -> () {
        return try repository.deleteAccount(forId: id)
    }

    public func updateAccount(id: UUID, data: AccountPatch) throws -> Account {
        var accountData = try repository.getAccountData(forId: id)

        if let name = data.name {
            accountData.name = name
        }

        if let phone = data.phone {
            accountData.phone = phone
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

        try accountData.validate()
        return try repository.updateAccountData(forId: id, data: accountData)
    }

    public func deleteAccountProperty(id: UUID, data: AccountPropertyDeletionPatch) throws -> Account {
        var accountData = try repository.getAccountData(forId: id)

        if (data.removePhone ?? false) {
            accountData.phone = nil
        }

        if let index = data.removeAddressAt {
            accountData.address.remove(at: index)
        }

        return try repository.updateAccountData(forId: id, data: accountData)
    }
}
