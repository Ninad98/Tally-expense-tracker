//
//  Currency.swift
//  Tally
//
//  Created by Mazen Tarek on 3/14/26.
//

import Foundation

struct Currency: Identifiable, Equatable {
    let id: String
    let name: String
    let symbol: String
    let flagAsset: String

    static let available: [Currency] = [
        Currency(id: "USD", name: "United States Dollar", symbol: "$",    flagAsset: "flag-usa"),
        Currency(id: "EUR", name: "Euro",                 symbol: "€",    flagAsset: "flag-eu"),
        Currency(id: "GBP", name: "British Pound",        symbol: "£",    flagAsset: "flag-uk"),
        Currency(id: "AUD", name: "Australian Dollar",    symbol: "A$",   flagAsset: "flag-aus"),
        Currency(id: "AED", name: "UAE Dirham",           symbol: "د.إ", flagAsset: "flag-uae")
    ]

    static func currency(forCountryCode code: String) -> Currency? {
        switch code.uppercased() {
        case "US":
            return available.first { $0.id == "USD" }
        case "GB":
            return available.first { $0.id == "GBP" }
        case "AU":
            return available.first { $0.id == "AUD" }
        case "AE":
            return available.first { $0.id == "AED" }
        case "AT", "BE", "CY", "EE", "FI", "FR", "DE", "GR", "IE",
             "IT", "LV", "LT", "LU", "MT", "NL", "PT", "SK", "SI", "ES":
            return available.first { $0.id == "EUR" }
        default:
            return nil
        }
    }
}
