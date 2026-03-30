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
}
