import Foundation

protocol AccountStore {
    func createAccount(data: AccountData) -> Account?
}

extension MemoryStore: AccountStore {
    func createAccount(data: AccountData) -> Account? {
        if !isValidEmail(data.email) {
            return nil
        }

        if self.getAccountForEmail(email: data.email) != nil {
            return nil
        }

        let id = UUID()
        let date = Date()
        let account = Account(id: id, createdOn: date,
                              updatedAt: date, data: data)
        self.createIdForEmail(email: data.email, id: id)
        self.createAccountWithId(id: id, account: account)
        return account
    }
}
