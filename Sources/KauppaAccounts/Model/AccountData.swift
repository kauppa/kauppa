import Foundation

import KauppaCore

/// User-supplied data for an account.
public struct AccountData: Mappable {
    /// Name of the user
    public var name: String = ""
    /// User's email
    public var email: String = ""
    /// User's phone number
    public var phone: String? = nil
    /// A list of user's addresses
    public var address = ArraySet<Address>()

    /// Try some basic validations on the data.
    public func validate() throws {
        if name.isEmpty {
            throw AccountsError.invalidName
        }

        /// A popular regex pattern that matches a wide range of cases.
        if !email.isMatching(regex: "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)") {
            throw AccountsError.invalidEmail
        }

        if let number = phone {
            if number.isEmpty {
                throw AccountsError.invalidPhone
            }
        }

        for addr in address {
            try addr.validate()
        }
    }

    public init() {}
}
