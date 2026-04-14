//
//  BiometricAuthManager.swift
//  Tally
//
//  Created by Mazen Tarek on 4/14/26.
//

import Combine
import LocalAuthentication
import SwiftUI

// Attribution: https://developer.apple.com/documentation/localauthentication/lacontext
final class BiometricAuthManager: ObservableObject {

    private static let userDefaultsKey = "biometricLockEnabled"

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.userDefaultsKey)
        }
    }

    // This is to check if the device has biometrics.
    @Published var isAvailable: Bool = false
    // This tracks when the app is locked and requires biometrics to unlock.
    @Published var isLocked: Bool = false

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: Self.userDefaultsKey)
        checkAvailability()
    }

    func checkAvailability() {
        let context = LAContext()
        var error: NSError?
        isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock Tally"
            )
            return success
        } catch {
            print("Biometric auth failed: \(error.localizedDescription)")
            return false
        }
    }
}
