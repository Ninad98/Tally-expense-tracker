//
//  LoginViewModel.swift
//  Tally
//
//  Created by Ninad Mankar on 3/20/26.
//
// Updated by Mazen Tarek on 3/27/26.
//

import Combine
import FirebaseAuth
import SwiftUI

final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var authError: String?
    @Published var isPasswordVisible: Bool = false
    @Published var isLoading: Bool = false

    var isFormValid: Bool {
        emailError == nil && passwordError == nil &&
            !email.isEmpty && !password.isEmpty
    }

    // escaping is used with async execution
    func login(onSuccess: @escaping () -> Void) {
        authError = nil
        validateEmail()
        validatePassword()
        guard isFormValid else { return }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        isLoading = true

        // Sign-in: https://firebase.google.com/docs/auth/ios/start#sign_in_existing_users
        Task {
            do {
                _ = try await Auth.auth().signIn(withEmail: trimmedEmail, password: password)
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
        } else {
            passwordError = nil
        }
    }

    private func mapFirebaseAuthError(_ error: Error) {
        switch FirebaseAuthErrorMapping.map(error, flow: .login) {
        case .email(let message): emailError = message
        case .password(let message): passwordError = message
        case .auth(let message): authError = message
        }
    }
}
