import KauppaTaxStore

/// Manages the retrieval and persistance of tax data from store.
public class TaxRepository {
    let store: TaxStorable

    public init(withStore store: TaxStorable) {
        self.store = store
    }
}
