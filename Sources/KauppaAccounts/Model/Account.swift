import Foundation

import KauppaCore

/// Account structure that exists in repository and store.
public struct Account: Mappable {
    /// Unique identifier for this account.
    public var id: UUID?
    /// Creation timestamp
    public var createdOn: Date?
    /// Last updated timestamp
    public var updatedAt: Date?
    /// First name of the user
    public var firstName: String = ""
    /// Last name of the user
    public var lastName: String? = nil
    /// User's emails
    public var emails = ArraySet<Email>()
    /// User's phone number
    public var phoneNumbers: ArraySet<Phone>? = ArraySet()
    /// A list of user's addresses
    public var address: [Address]? = nil

    /// Checks whether the account has at least one verified email.
    public var isVerified: Bool {
        return emails.get(matching: { $0.isVerified }) != nil
    }

    /// Initialize this `Account` (for tests).
    // FIXME: Remove 'public' modifier.
    public init() {
        self.id = UUID()
        let date = Date()
        self.createdOn = date
        self.updatedAt = date
    }

    /// Try some basic validations on the data. It checks that the name and emails aren't empty,
    /// evaluates the emails against a regex and validates addresses (if specified).
    ///
    /// - Throws: `ServiceError` if any of the underlying data fails during validation.
    public func validate() throws {
        if firstName.isEmpty {
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

        for number in phoneNumbers ?? ArraySet() {
            if number.value.isEmpty {
                throw ServiceError.invalidAccountPhone
            }
        }

        for addr in address ?? [] {
            try addr.validate()
        }
    }

    /// Get the list of verified emails associated with this account.
    ///
    /// - Returns: An array of verified emails from this account.
    public func getVerifiedEmails() -> [String] {
        return Array(emails.filter { $0.isVerified }).map { $0.value }
    }
}
