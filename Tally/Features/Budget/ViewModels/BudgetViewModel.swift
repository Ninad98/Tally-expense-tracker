//
//  BudgetViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 3/30/26.
//

import Combine
import FirebaseAuth
import SwiftUI

final class BudgetViewModel: ObservableObject {

    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    @Published var budget: Budget? = nil
    @Published var isLoading: Bool = true
    @Published var monthlyTransactions: [AppTransaction] = []

    // This is calculated from all the category limits.
    var totalLimit: Double {
        budget?.totalLimitBase ?? 0
    }

    // This is the list of limits for each category.
    var categoryLimits: [CategoryLimit] {
        budget?.categoryLimits ?? []
    }

    // This is the total spent on all categories, computed from expenses added.
    var totalSpent: Double {
        monthlyTransactions
            .filter { !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }

    // This is the total remaining budget.
    var totalRemaining: Double {
        max(totalLimit - totalSpent, 0)
    }

    // This is the progress of the budget in percentage, for the bar to show amount spent.
    var progress: Double {
        guard totalLimit > 0 else { return 0 }
        return min(totalSpent / totalLimit, 1.0)
    }

    var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    // This is to check if the user has a budget set or not yet.
    var hasBudget: Bool { budget != nil }

    func spentForCategory(_ categoryId: String) -> Double {
        monthlyTransactions
            .filter { !$0.isIncome && $0.categoryId == categoryId }
            .reduce(0) { $0 + $1.amount }
    }

    func loadBudget() {
        isLoading = true
        Task {
            guard let uid = Auth.auth().currentUser?.uid else {
                await MainActor.run { isLoading = false }
                return
            }

            async let fetchedBudget = firebaseService.fetchActiveBudget(uid: uid)
            async let fetchedTransactions = firebaseService.fetchMonthlyTransactions(uid: uid)

            let (budget, transactions) = await (fetchedBudget, fetchedTransactions)

            await MainActor.run {
                self.budget = budget
                self.monthlyTransactions = transactions
                isLoading = false
            }
        }
    }
}
