//
//  ForgotPasswordViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 4/18/26.
//

import Combine
import FirebaseAuth
import SwiftUI

final class ForgotPasswordViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var submittedEmail: String = ""
    @Published var showCheckEmail = false

    // Firebase handles sending the email, we have to just specify the email.
    func sendPasswordReset() {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter your email address."
            return
        }
        guard isValidEmailFormat(trimmed) else {
            errorMessage = "Enter a valid email address."
            return
        }

        errorMessage = nil
        isLoading = true

        Task {
            do {
                try await Self.sendPasswordResetToEmail(trimmed)
                await MainActor.run {
                    submittedEmail = trimmed
                    isLoading = false
                    showCheckEmail = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = FirebaseAuthErrorMapping.mapPasswordReset(error)
                }
            }
        }
    }

    private func isValidEmailFormat(_ value: String) -> Bool {
        value.contains("@") && value.contains(".")
    }

    // Attribution: GenAI helped me with this function to invoke firebase to send the reset email.
    private static func sendPasswordResetToEmail(_ email: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
