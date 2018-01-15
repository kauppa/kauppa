import Foundation

/// Possible errors for invalid address.
public enum AddressError: UInt8 {
    case invalidLineData = 0
    case invalidCity     = 1
    case invalidCountry  = 2
    case invalidCode     = 3
    case invalidLabel      = 4
    case invalidName     = 5

    func source() -> String {
        switch self {
            case .invalidLineData:
                return "line data"
            case .invalidCity:
                return "city"
            case .invalidCountry:
                return "country"
            case .invalidCode:
                return "code"
            case .invalidLabel:
                return "tag"
            case .invalidName:
                return "name"
        }
    }
}

/// Accounts service errors
public enum AccountsError: Error {
    case accountExists
    case invalidEmail
    case emailRequired
    case invalidAccount
    case invalidName
    case invalidPhone
    /// Indicates an error in the address. This holds information about
    /// which part of the address went wrong.
    case invalidAddress(AddressError)
}

extension AccountsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .accountExists:
                return "Account already exists"
            case .invalidEmail:
                return "Error validating email"
            case .emailRequired:
                return "Account requires at least one email"
            case .invalidAccount:
                return "No account found for the given UUID"
            case .invalidName:
                return "Invalid name in data"
            case .invalidPhone:
                return "Invalid phone number in data"
            case let .invalidAddress(e):
                return "Invalid \(e.source()) in address"
        }
    }
}

extension AccountsError: Equatable {
    /// Check the equality of this result.
    public static func ==(lhs: AccountsError, rhs: AccountsError) -> Bool {
        switch (lhs, rhs) {
            case (.accountExists, .accountExists),
                 (.invalidEmail, .invalidEmail),
                 (.emailRequired, .emailRequired),
                 (.invalidAccount, .invalidAccount),
                 (.invalidName, .invalidName),
                 (.invalidPhone, .invalidPhone):
                return true
            case let (.invalidAddress(s1), .invalidAddress(s2)):
                return s1.rawValue == s2.rawValue
            default:
                return false
        }
    }
}
