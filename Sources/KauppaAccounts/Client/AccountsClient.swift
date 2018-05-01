import Foundation

import KauppaCore
import KauppaAccountsModel

/// HTTP client for the accounts service.
public class AccountsServiceClient<C: ClientCallable>: ServiceClient<C, AccountsRoutes>, AccountsServiceCallable {
    public func createAccount(with data: Account) throws -> Account {
        let client = try createClient(for: .createAccount)
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func verifyEmail(_ email: String) throws -> () {
        let client = try createClient(for: .verifyEmail)
        var data = AccountPropertyAdditionPatch()
        data.email = Email(email)
        try client.setJSON(using: data)
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }

    public func getAccount(for id: UUID) throws -> Account {
        let client = try createClient(for: .getAccount, with: ["id": id])
        return try requestJSON(with: client)
    }

    public func deleteAccount(for id: UUID) throws -> () {
        let client = try createClient(for: .deleteAccount, with: ["id": id])
        let _: ServiceStatusMessage = try requestJSON(with: client)
    }

    public func updateAccount(for id: UUID, with data: AccountPatch) throws -> Account {
        let client = try createClient(for: .updateAccount, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func addAccountProperty(to id: UUID, using data: AccountPropertyAdditionPatch) throws -> Account {
        let client = try createClient(for: .addAccountProperty, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }

    public func deleteAccountProperty(from id: UUID, using data: AccountPropertyDeletionPatch) throws -> Account {
        let client = try createClient(for: .deleteAccountProperty, with: ["id": id])
        try client.setJSON(using: data)
        return try requestJSON(with: client)
    }
}
