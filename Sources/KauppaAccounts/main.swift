import Foundation

import Kitura

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsRepository
import KauppaAccountsService
import KauppaAccountsStore

var accountData = AccountData()
accountData.name = "Richard Hendricks"
var email = Email("richard.hendricks@piedpiper.com")
email.isVerified = true
accountData.emails.insert(email)
var account = Account(with: accountData)
account.id = "BAADA555-0B16-B00B-CAFE-BABE8BADF00D".parse()!

let repository = AccountsRepository(with: AccountsNoOpStore())
let accountsService = AccountsService(with: repository)
let _ = try! accountsService.createAccount(with: accountData)

let router = Router()
let serviceRouter = AccountsRouter(with: router, service: accountsService)

let servicePort = Int.from(environment: "KAUPPA_SERVICE_PORT") ?? 8090
print("Listening to requests on port \(servicePort)")

// FIXME: This should be managed by the controller
Kitura.addHTTPServer(onPort: servicePort, with: router)

Kitura.run()
