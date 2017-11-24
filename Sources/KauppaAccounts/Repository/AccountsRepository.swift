import Foundation

import KauppaCore
import KauppaAccountsModel

// Manages the retrievable and persistance of accounts data
// inline with the business logic requirements.
public class AccountsRepository: AccountsDepositing {

    public var accounts: [UUID: Account]

    private var store: AccountsStoring

    public init() {
        self.accounts = [UUID: Account]()
        self.store = AccountsStore()
    }

    public init(store: AccountsStoring) {
        self.accounts = [UUID: Account]()
        self.store = store
    }

    func createAccount(data: AccountData) -> Account? {
        if !isValidEmail(data.email) {
            return nil
        }

        //TODO: if self.getAccountForEmail(email: data.email) != nil {
        //    return nil
        //}

        let id = UUID()
        let date = Date()
        let account = Account(id: id, createdOn: date,
                              updatedAt: date, data: data)
        //TODO: self.createIdForEmail(email: data.email, id: id)
        //TODO: self.createAccountWithId(id: id, account: account)
        return account
    }
}