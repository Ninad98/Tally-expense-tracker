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
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            emailError = "Email is required"
        } else if !isValidEmailFormat(email) {
            emailError = "Invalid email"
        } else {
            emailError = nil
        }
    }

    func setEmailAlreadyInUseError() {
        emailError = "This email is already in use."
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
        let ns = error as NSError
        guard ns.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: ns.code) else {
            authError = error.localizedDescription
            return
        }
        switch code {
        case .emailAlreadyInUse:
            emailError = "This email is already in use."
        case .invalidEmail:
            emailError = "Invalid email"
        case .weakPassword:
            passwordError = "Password must be at least 8 characters."
        case .networkError:
            authError = "Network error. Try again."
        case .operationNotAllowed:
            authError = "Email sign-in is not enabled for this app."
        default:
            authError = error.localizedDescription
        }
    }

    private func isValidEmailFormat(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.contains("@"), let at = trimmed.firstIndex(of: "@") else { return false }
        let domain = trimmed[trimmed.index(after: at)...]
        return domain.contains(".") && trimmed.count > 3
    }
}
