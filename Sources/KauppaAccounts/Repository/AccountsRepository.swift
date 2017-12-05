import Foundation

import KauppaCore
import KauppaAccountsModel
import KauppaAccountsStore

// Manages the retrievable and persistance of accounts data
// inline with the business logic requirements.
public class AccountsRepository {

    public var accounts: [UUID: Account]

    var store: AccountsStorable

    public init(withStore store: AccountsStorable) {
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
