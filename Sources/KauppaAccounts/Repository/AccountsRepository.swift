import Foundation

import KauppaCore
import KauppaAccountsModel

public class AccountsRepository {

    public var accounts: [UUID: Account]

    public init() {
        self.accounts = [UUID: Account]()
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