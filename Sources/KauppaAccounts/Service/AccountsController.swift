import KauppaCore
import KauppaAccountsRepository

/// Controls the flow of information from the service end-points,
/// through to the domain repository.
public class AccountsController: ServiceController {

    let service: AccountsService? = nil

    let router: AccountsRouter? = nil

    /// Initializes a new `AccountsController`.
    public override init() {
        super.init()
    }

    func startService() {

    }
}
