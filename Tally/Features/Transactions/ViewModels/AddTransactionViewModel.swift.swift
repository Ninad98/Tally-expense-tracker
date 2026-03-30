//
//  AddTransactionViewModel.swift.swift
//  Tally
//
//  Created by Ninad Mankar on 3/30/26.
//

import Combine
import FirebaseAuth
import SwiftUI

final class AddTransactionViewModel: ObservableObject {

    @Published var title: String = ""
    @Published var amountText: String = ""
    @Published var selectedCategoryId: String = ""
    @Published var transactionType: TransactionType = .expense
    @Published var date: Date = Date()
    @Published var note: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var categories: [CategoryLimit] = []

    @Published var titleError: String?
    @Published var amountError: String?

    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    var selectedCategory: CategoryLimit? {
        categories.first { $0.id == selectedCategoryId }
    }

    func loadCategories() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            let budget = await firebaseService.fetchActiveBudget(uid: uid)
            await MainActor.run {
                categories = budget?.categoryLimits ?? CategoryLimit.defaults
                if selectedCategoryId.isEmpty, let first = categories.first {
                    selectedCategoryId = first.id
                }
            }
        }
    }

    func save(onSuccess: @escaping () -> Void) {
        titleError = nil
        amountError = nil
        errorMessage = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            titleError = "Please enter a title"
            return
        }

        guard let parsedAmount = Double(amountText), parsedAmount > 0 else {
            amountError = "Please enter a valid amount"
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not found. Please log in again."
            return
        }

        let category = selectedCategory ?? CategoryLimit.defaults[0]

        isLoading = true
        Task {
            do {
                try await firebaseService.addTransaction(
                    uid: uid,
                    title: trimmedTitle,
                    amount: parsedAmount,
                    categoryId: category.id,
                    categoryName: category.name,
                    categoryIcon: category.icon,
                    type: transactionType,
                    date: date,
                    note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                await MainActor.run {
                    isLoading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
