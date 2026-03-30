//
//  CurrencyFormatter.swift
//  Tally
//
//  Created by Mazen Tarek on 3/30/26.
//

import Foundation

// Helper function to format value as currency format as it is used multiple times in the app.
extension Double {
    func asCurrency(symbol: String = "$") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(symbol)0.00"
    }
}
