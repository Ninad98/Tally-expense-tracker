//
//  Budget.swift
//  Tally
//
//  Created by Mazen Tarek on 3/29/26.
//

import Foundation

struct CategoryLimit: Identifiable {
    let id: String
    var name: String
    var description: String
    var icon: String
    var limit: Double
    var isCustom: Bool = false // I added this to differentiate between user custom categories and the default one.

    static let defaults: [CategoryLimit] = [
        CategoryLimit(id: "food", name: "Food & Dining", description: "Restaurants, groceries", icon: "fork.knife", limit: 0),
        CategoryLimit(id: "transport", name: "Transport", description: "Fuel, public transit, Uber", icon: "car", limit: 0),
        CategoryLimit(id: "shopping", name: "Shopping", description: "Clothing, electronics", icon: "bag", limit: 0),
        CategoryLimit(id: "entertainment", name: "Entertainment", description: "Movies, games, events", icon: "film", limit: 0),
        CategoryLimit(id: "bills", name: "Bills & Utilities", description: "Rent, electricity, internet", icon: "bolt", limit: 0),
        CategoryLimit(id: "health", name: "Health & Fitness", description: "Gym, medicine, pharmacy", icon: "heart", limit: 0),
        CategoryLimit(id: "housing", name: "Housing", description: "Rent, mortgage, utilities", icon: "house", limit: 0)
    ]
}

struct Budget: Identifiable {
    let id: String
    let name: String
    let period: String
    let totalLimitBase: Double
    let categoryLimits: [CategoryLimit]
    let createdAt: Date?
    let updatedAt: Date?
}
