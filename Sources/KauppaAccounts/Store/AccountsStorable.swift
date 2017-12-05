import Foundation

import KauppaAccountsModel

/// Protocol to unify mutating and non-mutating methods.
public protocol AccountsStorable: AccountsPersisting, AccountsQuerying {
    //
}
