import KauppaTaxModel

/// Configuration object for the tax service.
struct TaxConfiguration {
    /// Minimum allowed value for tax rate in percentage.
    static var minTaxRatePercent: Double = 0.0
    /// Maximum allowed value for tax rate in percentage.
    static var maxTaxRatePercent: Double = 1000.0   // disallow rates > 1000%
}

extension TaxRate {
    /// Validate tax rate using the tax service configuration.
    ///
    /// - Throws: `TaxError` for invalid data.
    public func validate() throws {
        if general < TaxConfiguration.minTaxRatePercent
           || general > TaxConfiguration.maxTaxRatePercent
        {
            throw TaxError.invalidTaxRate
        }

        for (category, rate) in categories {
            if rate < TaxConfiguration.minTaxRatePercent
               || rate > TaxConfiguration.maxTaxRatePercent
            {
                throw TaxError.invalidCategoryTaxRate(category)
            }
        }
    }
}

extension Country {
    /// Validate country data (name and tax rate).
    ///
    /// - Throws: `TaxError` for invalid data.
    public func validate() throws {
        if name.isEmpty {
            throw TaxError.invalidCountryName
        }

        try taxRate.validate()
    }
}

extension Region {
    /// Validate region's data (name and tax rate).
    ///
    /// - Throws: `TaxError` for invalid data.
    public func validate() throws {
        if name.isEmpty {
            throw TaxError.invalidRegionName
        }

        try taxRate.validate()
    }
}
