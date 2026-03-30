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

    // This is calculated from all the category limits.
    var totalLimit: Double {
        budget?.totalLimitBase ?? 0
    }

    // This is the list of limits for each category.
    var categoryLimits: [CategoryLimit] {
        budget?.categoryLimits ?? []
    }

    // This is the total spent on all categories, computed from expenses added.
    var totalSpent: Double { 0 }

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
    var hasBudget: Bool {
        budget != nil
    }

    func loadBudget() {
        isLoading = true
        Task {
            guard let user = Auth.auth().currentUser else {
                await MainActor.run { isLoading = false }
                return
            }

            let fetchedBudget = await firebaseService.fetchActiveBudget(uid: user.uid)

            await MainActor.run {
                budget = fetchedBudget
                isLoading = false
            }
        }
    }
}
