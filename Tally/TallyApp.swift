//
//  TallyApp.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import SwiftUI

enum AppScreen {
    case splash
    case onboarding
    case currencySelection(fromOnboarding: Bool)
    case login
    case home
}

@main
struct TallyApp: App {
    @AppStorage("splashShown") private var splashShown: Bool = false
    @AppStorage("onboardingCompleted") private var onboardingCompleted: Bool = false
    @AppStorage("currencySelected") private var currencySelected: Bool = false

    @State private var screen: AppScreen = .splash

    init() {
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
                    LoginView {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            screen = .home
                        }
                    }

                case .home:
                    HomeView()
                }
            }
        }
    }
}
