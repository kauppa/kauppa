import KauppaCore
import KauppaAccountsRepository

public class AccountsController: ServiceController {

    public override init() {
        super.init()
    }

    public init(withRepository repository: AccountsDepositing) {
        super.init()
    }

    public override func startService() {
        super.startService()
    }
}