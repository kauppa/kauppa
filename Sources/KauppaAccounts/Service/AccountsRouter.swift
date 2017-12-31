import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsClient

/// Router specific to the accounts service.
public class AccountsRouter<R: Routing>: ServiceRouter<R, AccountsRoutes> {
    let service: AccountsServiceCallable

    /// Initializes this router with a `Routing` object and
    /// an `AccountsServiceCallable` object.
    public init(with router: R, service: AccountsServiceCallable) {
        self.service = service
        super.init(with: router)
    }

    /// Overridden routes for accounts service.
    public override func initializeRoutes() {
        add(route: .createAccount) { request, response in
            guard let data: AccountData = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let account = try self.service.createAccount(with: data)
            response.respondJSON(with: account, code: .ok)
        }

        add(route: .verifyEmail) { request, response in
            guard let data: AccountPropertyAdditionPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            guard let email = data.email else {
                throw ServiceError.invalidAccountEmail
            }

            try self.service.verifyEmail(email.value)
            response.respondJSON(with: ServiceStatusMessage(), code: .ok)
        }

        add(route: .getAccount) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidAccountId
            }

            let account = try self.service.getAccount(for: id)
            response.respondJSON(with: account, code: .ok)
        }

        add(route: .deleteAccount) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidAccountId
            }

            try self.service.deleteAccount(for: id)
            response.respondJSON(with: ServiceStatusMessage(), code: .ok)
        }

        add(route: .updateAccount) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidAccountId
            }

            guard let data: AccountPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let account = try self.service.updateAccount(for: id, with: data)
            response.respondJSON(with: account, code: .ok)
        }

        add(route: .addAccountProperty) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidAccountId
            }

            guard let data: AccountPropertyAdditionPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let account = try self.service.addAccountProperty(to: id, using: data)
            response.respondJSON(with: account, code: .ok)
        }

        add(route: .deleteAccountProperty) { request, response in
            guard let id: UUID = request.getParameter(for: "id") else {
                throw ServiceError.invalidAccountId
            }

            guard let data: AccountPropertyDeletionPatch = request.getJSON() else {
                throw ServiceError.clientHTTPData
            }

            let account = try self.service.deleteAccountProperty(from: id, using: data)
            response.respondJSON(with: account, code: .ok)
        }
    }
}
