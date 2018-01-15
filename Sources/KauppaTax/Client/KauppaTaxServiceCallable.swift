import Foundation

import KauppaAccountsModel
import KauppaTaxModel

/// General API for the tax service to be implemented by both the service
/// and the client.
public protocol TaxServiceCallable {
    func calculateVAT(forAddress address: Address) throws -> ValueAddedTax
}
