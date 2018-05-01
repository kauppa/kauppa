import KauppaCore
import KauppaAccountsModel

/// Data required for placing an order from the cart.
public struct CheckoutData: Mappable {
    /// Shipping address for this order.
    public var shippingAddress: Address? = nil
    /// Billing address for this order.
    public var billingAddress: Address? = nil
    /// Represents the index of an `Address` in `Account` to be used for shipping address.
    public var shippingAddressAt: Int? = 0
    /// Represents the index of an `Address` in `Account` to be used for billing address.
    public var billingAddressAt: Int? = nil

    /// Validates the addresses using the given account data. If the shipping/billing address
    /// is absent and if an index is given for it, then the address is obtained from the
    /// account. The addresses supersede the address indices. If
    ///
    /// - Parameters:
    ///   - using: The `Account` provided.
    /// - Throws: `ServiceError` if the address data is insufficient.
    public mutating func validate(using data: Account) throws {
        let addressList = data.address ?? []

        if shippingAddress == nil && shippingAddressAt != nil {
            let index = shippingAddressAt!
            if index >= addressList.count {
                throw ServiceError.invalidAddress
            }

            shippingAddress = addressList[index]
        }

        if billingAddress == nil && billingAddressAt != nil {
            let index = billingAddressAt!
            if index >= addressList.count {
                throw ServiceError.invalidAddress
            }

            billingAddress = addressList[index]
        }

        if shippingAddress == nil {
            throw ServiceError.invalidAddress
        }

        shippingAddressAt = nil
        billingAddressAt = nil
    }
}
