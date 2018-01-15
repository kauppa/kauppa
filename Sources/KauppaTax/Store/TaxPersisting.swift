import KauppaCore
import KauppaTaxModel

/// Methods that mutate the underlying store with information.
public protocol TaxPersisting: Persisting {
    /// Create a country with data from the repository.
    func createCountry(with data: Country) throws -> ()
}
