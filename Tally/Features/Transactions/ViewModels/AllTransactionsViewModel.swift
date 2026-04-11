//
//  AllTransactionsViewModel.swift
//  Tally
//
//  Created by Ninad Mankar on 4/11/26.
//

import Combine
import FirebaseAuth
import SwiftUI

final class AllTransactionsViewModel: ObservableObject {

    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    @Published var isLoading: Bool = true
    @Published var allTransactions: [AppTransaction] = []

    // Groups transactions by "Month Year" string e.g. "April 2026"
    // Keeps the groups sorted from most recent month to oldest.
    var groupedTransactions: [(month: String, transactions: [AppTransaction])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        // Build a dict of month string -> transactions array.
        var dict: [String: [AppTransaction]] = [:]
        for tx in allTransactions {
            let key = formatter.string(from: tx.date)
            dict[key, default: []].append(tx)
        }

        // Sort months from most recent to oldest.
        let sortedKeys = dict.keys.sorted { a, b in
            let dateA = formatter.date(from: a) ?? .distantPast
            let dateB = formatter.date(from: b) ?? .distantPast
            return dateA > dateB
        }

        return sortedKeys.map { key in
            (month: key, transactions: dict[key] ?? [])
        }
    }

    // Total income across all transactions.
    var totalIncome: Double {
        allTransactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    // Total expenses across all transactions.
    var totalExpenses: Double {
        allTransactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    func loadTransactions() {
        isLoading = true
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }

        Task {
            let transactions = await firebaseService.fetchAllTransactions(uid: uid)
            await MainActor.run {
                allTransactions = transactions
                isLoading = false
            }
        }
    }
}
