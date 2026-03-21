//
//  LoginViewModel.swift
//  Tally
//
//  Created by Ninad Mankar on 3/20/26.
//

import Combine
import SwiftUI

final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var isPasswordVisible: Bool = false
    @Published var isLoading: Bool = false

    var isFormValid: Bool {
        emailError == nil && passwordError == nil &&
        !email.isEmpty && !password.isEmpty
    }

    func login(onSuccess: () -> Void) {    // ← UPDATED
        validateEmail()
        validatePassword()
        guard isFormValid else { return }
        // TODO: Wire up Firebase auth later
        onSuccess()                        // ← UPDATED
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
        } else if password.count < 6 {
            passwordError = "Invalid password"
        } else {
            passwordError = nil
        }
    }
}
