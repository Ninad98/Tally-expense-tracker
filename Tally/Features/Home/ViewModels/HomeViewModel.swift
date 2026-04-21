//
//  HomeViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import Combine
import FirebaseAuth
import SwiftUI

final class HomeViewModel: ObservableObject {

    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    @Published var isLoading: Bool = true
    @Published var fullName: String = ""
    @Published var recentTransactions: [AppTransaction] = []
    @Published var monthlyIncome: Double = 0
    @Published var monthlyExpenses: Double = 0
    @Published var totalBalance: Double = 0
    @Published var balanceChangePercent: Double = 0
    @Published var budgetSpent: Double = 0
    @Published var budgetGoal: Double = 0

    var budgetProgress: Double {
        guard budgetGoal > 0 else { return 0 }
        return min(budgetSpent / budgetGoal, 1.0)
    }

    var budgetRemaining: Double {
        max(budgetGoal - budgetSpent, 0)
    }

    func loadData() {
        isLoading = true
        // https://firebase.google.com/docs/auth/ios/manage-users#swift_1
        // To get current authenticated user.
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }

        Task {
            // Fetches user's full name and active budget from Firebase.
            async let name = firebaseService.fetchUserFullName(uid: uid)
            async let recent = firebaseService.fetchRecentTransactions(uid: uid, limit: 5)
            async let monthly = firebaseService.fetchMonthlyTransactions(uid: uid)
            async let budget = firebaseService.fetchActiveBudget(uid: uid)
            async let previousMonth = Self.fetchPreviousMonthTransactions(uid: uid, service: firebaseService)

            let (fetchedName, recentTx, monthlyTx, fetchedBudget, previousMonthTx) = await (name, recent, monthly, budget, previousMonth)

            await MainActor.run {
                fullName = fetchedName ?? ""
                recentTransactions = recentTx

                monthlyIncome = monthlyTx
                    .filter { $0.isIncome }
                    .reduce(0) { $0 + $1.amount }

                monthlyExpenses = monthlyTx
                    .filter { !$0.isIncome }
                    .reduce(0) { $0 + $1.amount }

                totalBalance = monthlyIncome - monthlyExpenses

                // Sum previous month's income and expenses
                let previousIncome = previousMonthTx
                    .filter { $0.isIncome }
                    .reduce(0) { $0 + $1.amount }
                let previousExpenses = previousMonthTx
                    .filter { !$0.isIncome }
                    .reduce(0) { $0 + $1.amount }
                let previousBalance = previousIncome - previousExpenses

                // Compare previous month's balance with the current month's balance
                balanceChangePercent = Self.calculatePercentChange(
                    current: totalBalance,
                    previous: previousBalance
                )

                budgetGoal = fetchedBudget?.totalLimitBase ?? 0
                budgetSpent = monthlyExpenses

                isLoading = false
            }
        }
    }

    func deleteTransaction(_ transaction: AppTransaction) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                try await firebaseService.deleteTransaction(
                    uid: uid,
                    transactionId: transaction.id
                )
                await MainActor.run {
                    recentTransactions.removeAll { $0.id == transaction.id }

                    if transaction.isIncome {
                        monthlyIncome -= transaction.amount
                    } else {
                        monthlyExpenses -= transaction.amount
                        budgetSpent -= transaction.amount
                    }
                    totalBalance = monthlyIncome - monthlyExpenses
                }
            } catch {
                print("Failed to delete transaction: \(error.localizedDescription)")
            }
        }
    }

    private static func fetchPreviousMonthTransactions(
        uid: String,
        service: FirebaseServiceProtocol
    ) async -> [AppTransaction] {
        let calendar = Calendar.current
        let now = Date()
        guard let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) else {
            return []
        }
        return await service.fetchTransactions(uid: uid, from: previousMonthStart, to: currentMonthStart)
    }

    private static func calculatePercentChange(current: Double, previous: Double) -> Double {
        guard previous != 0 else {
            if current == 0 { return 0 }
            return current > 0 ? 100 : -100
        }
        return ((current - previous) / abs(previous)) * 100
    }
}
