//
//  TallyApp.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import FirebaseCore
import GoogleSignIn
import SwiftUI

enum AppScreen {
    case splash
    case onboarding
    case currencySelection(fromOnboarding: Bool)
    case login
    case signUp
    case home
}

@main
struct TallyApp: App {
    @AppStorage("splashShown") private var splashShown: Bool = false
    @AppStorage("onboardingCompleted") private var onboardingCompleted: Bool = false
    @AppStorage("currencySelected") private var currencySelected: Bool = false

    @Environment(\.scenePhase) private var isAppActive
    @StateObject private var biometricManager = BiometricAuthManager()
    @State private var screen: AppScreen = .splash
    @State private var appBackgroundedAt: Date?

    private let lockoutInterval: TimeInterval = 5

    init() {
        FirebaseApp.configure()

        let splash = UserDefaults.standard.bool(forKey: "splashShown")
        let onboarding = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        let currency = UserDefaults.standard.bool(forKey: "currencySelected")

        if !splash {
            _screen = State(initialValue: .splash)
        } else if !onboarding {
            _screen = State(initialValue: .onboarding)
        } else if !currency {
            _screen = State(initialValue: .currencySelection(fromOnboarding: false))
        } else {
            _screen = State(initialValue: .login)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch screen {
                case .splash:
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                splashShown = true
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    screen = onboardingCompleted
                                        ? (currencySelected ? .login : .currencySelection(fromOnboarding: false))
                                        : .onboarding
                                }
                            }
                        }

                case .onboarding:
                    OnboardingView {
                        onboardingCompleted = true
                        withAnimation(.easeInOut(duration: 0.6)) {
                            screen = .currencySelection(fromOnboarding: true)
                        }
                    }

                case .currencySelection(let fromOnboarding):
                    CurrencySelectionView(
                        onBack: fromOnboarding
                            ? {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    screen = .onboarding
                                }
                            }
                            : nil,
                        onComplete: { currency in
                            UserDefaults.standard.set(currency.id, forKey: "selectedCurrency")
                            currencySelected = true
                            withAnimation(.easeInOut(duration: 0.6)) {
                                screen = .login
                            }
                        }
                    )

                case .login:
                    LoginView(
                        onLoginSuccess: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                screen = .home
                            }
                        },
                        onSignUp: {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                screen = .signUp
                            }
                        }
                    )

                case .signUp:
                    SignUpFlowView(
                        onBackToLogin: {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                screen = .login
                            }
                        },
                        onGoogleSignIn: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                screen = .home
                            }
                        }
                    )

                case .home:
                // If app is locked and in backgroudn state for 5 seconds or more we show the biometric view page.
                    ZStack {
                        HomeView()

                        if biometricManager.isLocked {
                            BiometricLockView()
                                .transition(.opacity)
                        }
                    }
                }
            }
            .environmentObject(biometricManager)
            .onChange(of: isAppActive) { _, newPhase in
            // Check if biometric toggle is turned on or not.
                guard biometricManager.isEnabled, case .home = screen else { return }

                // if the state of the app was inactive or in the background we set the time.
                switch newPhase {
                case .background, .inactive:
                    if appBackgroundedAt == nil {
                        appBackgroundedAt = Date()
                    }
                case .active:
                    if let leftAt = appBackgroundedAt,
                       Date().timeIntervalSince(leftAt) >= lockoutInterval {
                        biometricManager.isLocked = true
                    }
                    appBackgroundedAt = nil
                @unknown default:
                    break
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
