import Loki

import KauppaCore
import KauppaTaxModel

/// Configuration object for the tax service.
public struct TaxConfiguration {
    /// Minimum allowed value for tax rate in percentage.
    public static var minTaxRatePercent: Float = 0.0
    /// Maximum allowed value for tax rate in percentage.
    public static var maxTaxRatePercent: Float = 1000.0    // disallow rates > 1000%
    /// Fallback tax rate when no country/region match for the address.
    public static var fallbackTaxRate = TaxRate()
}

extension TaxRate {
    /// Validate tax rate using the tax service configuration.
    ///
    /// - Throws: `ServiceError` for invalid data.
    public func validate() throws {
        if general < TaxConfiguration.minTaxRatePercent
           || general > TaxConfiguration.maxTaxRatePercent
        {
            Loki.warn("Tax rate \(general) is out of configured bounds")
            throw ServiceError.invalidTaxRate
        }

        for (name, rate) in categories {
            if rate < TaxConfiguration.minTaxRatePercent
               || rate > TaxConfiguration.maxTaxRatePercent
            {
                Loki.warn("Tax rate \(rate) for category \(name) is out of configured bounds")
                throw ServiceError.invalidCategoryTaxRate
            }
        }
    }
}

extension Country {
    /// Validate country data (name and tax rate).
    ///
    /// - Throws: `ServiceError` for invalid data.
    public func validate() throws {
        if name.isEmpty {
            throw ServiceError.invalidCountryName
        }

        try taxRate.validate()
    }
}

extension Region {
    /// Validate region's data (name and tax rate).
    ///
    /// - Throws: `ServiceError` for invalid data.
    public func validate() throws {
        if name.isEmpty {
            throw ServiceError.invalidRegionName
        }

        try taxRate.validate()
    }
}
