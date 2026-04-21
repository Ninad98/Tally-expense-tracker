//
//  FirebaseAuthErrorMapping.swift
//  Tally
//
//  Created by Mazen Tarek on 3/27/26.
//

import FirebaseAuth
import Foundation

// Centralized enum for mapping firebase auth errors
// GenAI helped me a bit here to refactor the code as I initially had duplicated code for login and sign up.
enum FirebaseAuthErrorMapping {

    enum Flow {
        case login
        case signUp
    }

    enum MappedMessage {
        case email(String)
        case password(String)
        case auth(String)
    }

    // https://firebase.google.com/docs/auth/ios/errors
    static func map(_ error: Error, flow: Flow) -> MappedMessage {
        let nsErr = error as NSError
        guard nsErr.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: nsErr.code) else {
            return .auth(error.localizedDescription)
        }

        switch code {
        case .invalidEmail:
            return .email("Invalid email")

        case .networkError:
            return .auth("Network error. Try again.")

        case .operationNotAllowed:
            return .auth("Email sign-in is not enabled for this app.")

        case .emailAlreadyInUse:
            if flow == .signUp {
                return .email("This email is already in use.")
            }
            return .auth(error.localizedDescription)

        case .weakPassword:
            if flow == .signUp {
                return .password("Password must be at least 8 characters.")
            }
            return .auth(error.localizedDescription)

        case .wrongPassword:
            if flow == .login {
                return .password("Incorrect password.")
            }
            return .auth(error.localizedDescription)

        case .userNotFound:
            if flow == .login {
                return .email("No account found for this email.")
            }
            return .auth(error.localizedDescription)

        case .userDisabled:
            return .auth("This account has been disabled.")

        case .invalidCredential:
            if flow == .login {
                return .auth("Invalid email or password.")
            }
            return .auth(error.localizedDescription)

        case .tooManyRequests:
            if flow == .login {
                return .auth("Too many attempts. Try again later.")
            }
            return .auth(error.localizedDescription)

        default:
            return .auth(error.localizedDescription)
        }
    }

    enum ChangePasswordMapped {
        case currentPassword(String)
        case newPassword(String)
        case general(String)
    }

    static func mapChangePassword(_ error: Error) -> ChangePasswordMapped {
        let nsErr = error as NSError
        guard nsErr.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: nsErr.code) else {
            return .general(error.localizedDescription)
        }

        switch code {
        case .wrongPassword:
            return .currentPassword("Current password is incorrect.")

        case .weakPassword:
            return .newPassword("Password must be at least 8 characters.")

        case .requiresRecentLogin:
            return .general("Please sign out and sign in again, then try changing your password.")

        case .invalidCredential:
            return .currentPassword("Current password is incorrect.")

        case .networkError:
            return .general("Network error. Try again.")

        case .tooManyRequests:
            return .general("Too many attempts. Try again later.")

        default:
            return .general(error.localizedDescription)
        }
    }

    static func mapPasswordReset(_ error: Error) -> String {
        let nsErr = error as NSError
        guard nsErr.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: nsErr.code) else {
            return error.localizedDescription
        }

        switch code {
        case .invalidEmail:
            return "Invalid email address."

        case .networkError:
            return "Network error. Try again."

        case .operationNotAllowed:
            return "Password reset is not enabled for this app."

        case .userNotFound:
            return "No account found for this email."

        case .tooManyRequests:
            return "Too many attempts. Try again later."

        case .userDisabled:
            return "This account has been disabled."

        default:
            return error.localizedDescription
        }
    }
}
