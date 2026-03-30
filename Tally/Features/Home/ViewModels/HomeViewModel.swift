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
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }

        Task {
            async let name = firebaseService.fetchUserFullName(uid: uid)
            async let recent = firebaseService.fetchRecentTransactions(uid: uid, limit: 5)
            async let monthly = firebaseService.fetchMonthlyTransactions(uid: uid)
            async let budget = firebaseService.fetchActiveBudget(uid: uid)

            let (fetchedName, recentTx, monthlyTx, fetchedBudget) = await (name, recent, monthly, budget)

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

                budgetGoal = fetchedBudget?.totalLimitBase ?? 0
                budgetSpent = monthlyExpenses

                isLoading = false
            }
        }
    }
}
