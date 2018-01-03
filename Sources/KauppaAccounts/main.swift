import Foundation

import Kitura

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsRepository
import KauppaAccountsService
import KauppaAccountsStore

class NoOpStore: AccountsStorable {
    public func createAccount(with data: Account) throws -> () {}

    public func getAccount(for id: UUID) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    public func getAccount(for email: String) throws -> Account {
        throw ServiceError.invalidAccountId
    }

    public func deleteAccount(for id: UUID) throws -> () {}

    public func updateAccount(with data: Account) throws -> () {}
}


let repository = AccountsRepository(with: NoOpStore())
let accountsService = AccountsService(with: repository)

let router = Router()
let serviceRouter = AccountsRouter(with: router, service: accountsService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
