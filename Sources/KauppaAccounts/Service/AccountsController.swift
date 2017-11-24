import KauppaCore
import KauppaAccountsRepository

/// Controls the flow of information from the service end-points, 
/// through to the domain repository.
public class AccountsController: ServiceController {

    let repository: AccountsDepositing?

    let service: AccountsService?

    let router: AccountsRouter?

    /// Initializes a new `AccountsController`.
    public override init() {
        repository = AccountsRepository()
        service = AccountsService(withDepositing: repository!)
        router = AccountsRouter()
        
        super.init()        
    }

    func startService() {
    
    }
}