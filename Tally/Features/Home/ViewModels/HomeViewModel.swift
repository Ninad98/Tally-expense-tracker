//
//  HomeViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import Combine
import FirebaseAuth
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

    private let firebaseService: FirebaseServiceProtocol
    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    @Published var isLoading: Bool = true
    @Published var fullName: String = ""
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
        Task {
            // https://firebase.google.com/docs/auth/ios/manage-users#swift_1
            // To get current authenticated user.
            guard let user = Auth.auth().currentUser else {
                await MainActor.run {
                    isLoading = false
                }
                return
            }

            // Fetches user's full name and active budget from Firebase.
            let name = await firebaseService.fetchUserFullName(uid: user.uid) ?? ""
            let budget = await firebaseService.fetchActiveBudget(uid: user.uid)

            await MainActor.run {
                fullName = name
                budgetGoal = budget?.totalLimitBase ?? 0
                // TODO: Budget spent calculated from expenses added
                isLoading = false
            }
        }
    }
}
