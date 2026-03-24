//
//  SignUpDoneView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/22/26.
//

import SwiftUI

struct SignUpDoneView: View {
    let onLogin: () -> Void

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            decorativeBackground

            VStack {
                Spacer(minLength: 0)

                VStack(spacing: 32) {
                    successMark

                    VStack(spacing: 12) {
                        Text("You're all set!")
                            .font(.urbanist(.extraBold, size: 32))
                            .foregroundStyle(Color.heading)
                            .tracking(-0.8)
                            .multilineTextAlignment(.center)

                        Text("Your account has been created.\nPlease login with your email and password.")
                            .font(.manrope(.medium, size: 16))
                            .foregroundStyle(Color.bodyText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 8)
                    }

                    Button(action: onLogin) {
                        Text("Login")
                            .font(.urbanist(.bold, size: 18))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.primaryBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(
                                color: Color.primaryBlue.opacity(0.25),
                                radius: 15,
                                x: 0,
                                y: 10
                            )
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
        }
        .preferredColorScheme(.light)
    }

    private var successMark: some View {
        ZStack {
            Circle()
                .fill(Color.primaryBlue.opacity(0.12))
                .frame(width: 120, height: 120)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.primaryBlue)
        }
    }

    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(Color.primaryBlue.opacity(0.12))
                .frame(width: 192, height: 192)
                .blur(radius: 48)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color.primaryBlue.opacity(0.08))
                .frame(width: 192, height: 192)
                .blur(radius: 48)
                .offset(x: 160, y: 320)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

#Preview("Sign up - Done") {
    SignUpDoneView(onLogin: {})
}
