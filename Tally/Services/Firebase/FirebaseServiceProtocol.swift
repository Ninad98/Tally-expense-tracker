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

    func fetchUserProfile(uid: String) async -> UserProfileSnapshot?

    func updateUserImage(uid: String, jpegBase64: String) async throws

    func updateUserFullName(uid: String, fullName: String) async throws

    func savePlaidLink(uid: String, itemID: String, institutionName: String?) async throws

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
        note: String,
        isRecurring: Bool
    ) async throws

    func importPlaidTransaction(
        uid: String,
        plaidTransactionId: String,
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

    func updateTransactionRecurringPaused(uid: String, transactionId: String, paused: Bool) async throws
    
    func fetchAllTransactions(uid: String) async -> [AppTransaction]
    
    func deleteTransaction(uid: String, transactionId: String) async throws
    
    func fetchTransactions(uid: String, from startDate: Date, to endDate: Date) async -> [AppTransaction]
    
}
