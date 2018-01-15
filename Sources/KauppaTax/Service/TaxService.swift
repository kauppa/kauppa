import KauppaAccountsModel
import KauppaTaxClient
import KauppaTaxModel
import KauppaTaxRepository

/// Public API for calculating various taxes for an order.
public class TaxService {
    let repository: TaxRepository

    /// Initializes a new `TaxService` instance with a repository.
    public init(withRepository repository: TaxRepository) {
        self.repository = repository
    }
}

// NOTE: See the actual protocol in `KauppaTaxClient` for exact usage.
extension TaxService: TaxServiceCallable {
    public func calculateVAT(forAddress address: Address) throws -> ValueAddedTax {
        return ValueAddedTax()
    }
}
