//
//  FirebaseServiceProtocol.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import Foundation

protocol FirebaseServiceProtocol {

    func saveUserToFirestore(
        uid: String,
        email: String,
        fullName: String,
        selectedCurrencyId: String?
    ) async throws

    func fetchUserFullName(uid: String) async -> String?

    func fetchActiveBudget(uid: String) async -> Budget?

    func saveBudget(uid: String, categoryLimits: [CategoryLimit], existingBudgetId: String?) async throws

    func addTransaction(
        uid: String,
        title: String,
        amount: Double,
        categoryId: String,
        categoryName: String,
        categoryIcon: String,
        type: TransactionType,
        date: Date,
        note: String
    ) async throws

    func fetchRecentTransactions(uid: String, limit: Int) async -> [AppTransaction]

    func fetchMonthlyTransactions(uid: String) async -> [AppTransaction]
}
