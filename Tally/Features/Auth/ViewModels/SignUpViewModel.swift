//
//  SignUpViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 3/22/26.
//

import Combine
import FirebaseAuth
import SwiftUI

final class SignUpViewModel: ObservableObject {

    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false

    @Published var fullNameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var authError: String?
    @Published var isLoading: Bool = false

    var isFormValid: Bool {
        fullNameError == nil && emailError == nil && passwordError == nil &&
            !fullName.isEmpty && !email.isEmpty && !password.isEmpty
    }

    func validateFullName() {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            fullNameError = "Please enter a valid full name."
        } else if trimmed.count < 2 {
            fullNameError = "Please enter a valid full name."
        } else if !trimmed.contains(where: { $0.isLetter }) {
            fullNameError = "Please enter a valid full name."
        } else {
            fullNameError = nil
        }
    }

    func validateEmail() {
        if email.isEmpty {
            emailError = "Email is required"
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Invalid email"
        } else {
            emailError = nil
        }
    }

    func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required"
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters."
        } else {
            passwordError = nil
        }
    }

    func validateAll() {
        validateFullName()
        validateEmail()
        validatePassword()
    }

    func createAccount(onSuccess: @escaping () -> Void) {
        authError = nil
        validateAll()
        guard isFormValid else { return }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)

        isLoading = true
        Task {
            do {
                let result = try await Auth.auth().createUser(withEmail: trimmedEmail, password: password)
                if !trimmedName.isEmpty {
                    let change = result.user.createProfileChangeRequest()
                    change.displayName = trimmedName
                    try await change.commitChanges()
                }
                await MainActor.run {
                    isLoading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    mapFirebaseAuthError(error)
                }
            }
        }
    }

    private func mapFirebaseAuthError(_ error: Error) {
        switch FirebaseAuthErrorMapping.map(error, flow: .signUp) {
        case .email(let message): emailError = message
        case .password(let message): passwordError = message
        case .auth(let message): authError = message
        }
    }
}
