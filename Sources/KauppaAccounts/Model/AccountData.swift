import Foundation

import KauppaCore

/// User-supplied data for an account.
public struct AccountData: Mappable {
    /// Name of the user
    public var name: String = ""
    /// User's emails
    public var emails = ArraySet<Email>()
    /// User's phone number
    public var phoneNumbers = ArraySet<Phone>()
    /// A list of user's addresses
    public var address = ArraySet<Address>()

    // FIXME: Remove this
    public init() {}

    /// Try some basic validations on the data. It checks that the name and emails aren't empty,
    /// evaluates the emails against a regex and validates addresses (if specified).
    ///
    /// - Throws: `ServiceError` if any of the underlying data fails during validation.
    public func validate() throws {
        if name.isEmpty {
            throw ServiceError.invalidAccountName
        }

        if emails.isEmpty {
            throw ServiceError.accountEmailRequired
        }

        for email in emails {
            /// A popular regex pattern that matches a wide range of cases.
            if !email.value.isMatching(regex: "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$)") {
                throw ServiceError.invalidAccountEmail
            }
        }

        for number in phoneNumbers {
            if number.value.isEmpty {
                throw ServiceError.invalidAccountPhone
            }
        }

        for addr in address {
            try addr.validate()
        }
    }

    /// Get the list of verified emails associated with this account.
    ///
    /// - Returns: An array of verified emails from this account.
    public func getVerifiedEmails() -> [String] {
        var list = [String]()
        for email in emails {
            if email.isVerified {
                list.append(email.value)
            }
        }

        return list
    }
}
