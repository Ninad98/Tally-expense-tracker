//
//  HomeViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import Combine
import SwiftUI

struct Transaction: Identifiable {
    let id: UUID
    let title: String
    let category: String
    let date: String
    let amount: Double
    let isIncome: Bool
    let iconName: String
}

final class HomeViewModel: ObservableObject {

    @Published var isLoading: Bool = true
    @Published var userName: String = ""
    @Published var totalBalance: Double = 0
    @Published var balanceChangePercent: Double = 0
    @Published var monthlyIncome: Double = 0
    @Published var monthlyExpenses: Double = 0
    @Published var budgetSpent: Double = 0
    @Published var budgetGoal: Double = 0
    @Published var recentTransactions: [Transaction] = []

    var budgetProgress: Double {
        guard budgetGoal > 0 else { return 0 }
        return min(budgetSpent / budgetGoal, 1.0)
    }

    var budgetRemaining: Double {
        max(budgetGoal - budgetSpent, 0)
    }

    func loadData() {
        isLoading = true
        // TODO: Replace with Firebase fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isLoading = false
        }
    }
}
