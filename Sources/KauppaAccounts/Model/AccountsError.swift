import Foundation

/// Accounts service errors
public enum AccountsError: Error {
    case accountExists
    case invalidEmail
    case invalidAccount
    case invalidName
}

extension AccountsError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .accountExists:
                return "Account already exists"
            case .invalidEmail:
                return "Error validating email"
            case .invalidAccount:
                return "No account found for the given UUID"
            case .invalidName:
                return "Invalid name in data"
        }
    }
}

extension AccountsError {
    /// Check the equality of this result.
    public static func ==(lhs: AccountsError, rhs: AccountsError) -> Bool {
        switch (lhs, rhs) {
            case (.accountExists, .accountExists),
                 (.invalidEmail, .invalidEmail),
                 (.invalidAccount, .invalidAccount),
                 (.invalidName, .invalidName):
                return true
            default:
                return false
        }
    }
}
