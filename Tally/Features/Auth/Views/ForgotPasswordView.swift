//
//  ForgotPasswordView.swift
//  Tally
//
//  Created by Mazen Tarek on 4/17/26.
//

import SwiftUI

struct ForgotPasswordView: View {

    let onBackToLogin: () -> Void

    @State private var email: String = ""
    @State private var didSendLink: Bool = false

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            if didSendLink {
                CheckYourEmailScreen(
                    email: email,
                    onOpenEmailApp: {},
                    onResend: {}
                )
            } else {
                ForgotPasswordFormScreen(
                    email: $email,
                    onBack: onBackToLogin,
                    onSendResetLink: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            didSendLink = true
                        }
                    },
                    onLoginTap: onBackToLogin
                )
            }
        }
    }
}

private struct ForgotPasswordFormScreen: View {

    @Binding var email: String
    let onBack: () -> Void
    let onSendResetLink: () -> Void
    let onLoginTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 0) {
                    titleSection
                        .padding(.top, 24)

                    iconBadge
                        .padding(.top, 40)

                    emailField
                        .padding(.top, 32)

                    sendResetLinkButton
                        .padding(.top, 24)
                }
                .padding(.horizontal, 16)
            }

            footer
                .padding(.bottom, 24)
        }
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primaryBlue)
                    .frame(width: 32, height: 32)
            }
            Spacer()
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Forgot Password?")
                .font(.urbanist(.extraBold, size: 32))
                .foregroundStyle(Color.heading)

            Text("Enter your email address.")
                .font(.manrope(.medium, size: 15))
                .foregroundStyle(Color.bodyText)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(Color.primaryBlue.opacity(0.1))
                .frame(width: 96, height: 96)

            Image(systemName: "lock.rotation")
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(Color.primaryBlue)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email Address")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.mutedText)
                    .frame(width: 20)

                TextField(
                    "",
                    text: $email,
                    prompt: Text("name@example.com").foregroundStyle(Color.mutedText)
                )
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.manrope(.regular, size: 16))
                .foregroundStyle(Color.heading)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
    }

    private var sendResetLinkButton: some View {
        Button(action: onSendResetLink) {
            HStack(spacing: 10) {
                Text("Send Reset Link")
                    .font(.urbanist(.bold, size: 17))
                    .foregroundStyle(.white)

                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty)
        .opacity(email.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text("Remember your password?")
                .font(.manrope(.regular, size: 14))
                .foregroundStyle(Color.bodyText)

            Button(action: onLoginTap) {
                Text("Login")
                    .font(.manrope(.bold, size: 14))
                    .foregroundStyle(Color.primaryBlue)
            }
        }
    }
}

private struct CheckYourEmailScreen: View {

    let email: String
    let onOpenEmailApp: () -> Void
    let onResend: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            envelopeBadge
            titleAndBody
                .padding(.top, 32)
                .padding(.horizontal, 32)

            openEmailAppButton
                .padding(.top, 32)
                .padding(.horizontal, 24)

            resendRow
                .padding(.top, 20)

            Spacer()
            brandFooter
                .padding(.bottom, 32)
        }
    }

    private var envelopeBadge: some View {
        ZStack {
            Circle()
                .fill(Color.primaryBlue.opacity(0.08))
                .frame(width: 160, height: 160)

            Circle()
                .fill(Color.white)
                .frame(width: 128, height: 128)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)

            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 56, weight: .regular))
                .foregroundStyle(Color.primaryBlue)
        }
    }

    private var titleAndBody: some View {
        VStack(spacing: 12) {
            Text("Check Your Email")
                .font(.urbanist(.extraBold, size: 28))
                .foregroundStyle(Color.heading)

            checkEmailBody
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var checkEmailBody: some View {
        let display = email.isEmpty ? "user@email.com" : email
        return VStack(spacing: 6) {
            Text("We've sent a password reset link to")
                .font(.manrope(.medium, size: 15))
                .foregroundStyle(Color.bodyText)

            Text(display)
                .font(.manrope(.bold, size: 15))
                .foregroundStyle(Color.primaryBlue)

            Text("Please check your inbox and follow the instructions.")
                .font(.manrope(.medium, size: 15))
                .foregroundStyle(Color.bodyText)
        }
        .frame(maxWidth: .infinity)
    }

    private var openEmailAppButton: some View {
        Button(action: onOpenEmailApp) {
            HStack(spacing: 10) {
                Text("Open Email App")
                    .font(.urbanist(.bold, size: 17))
                    .foregroundStyle(.white)

                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    private var resendRow: some View {
        VStack(spacing: 4) {
            Text("Didn't receive the email?")
                .font(.manrope(.regular, size: 14))
                .foregroundStyle(Color.bodyText)

            Button(action: onResend) {
                Text("Resend Link")
                    .font(.manrope(.bold, size: 14))
                    .foregroundStyle(Color.primaryBlue)
            }
        }
    }

    private var brandFooter: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.cardBorder)
                .frame(width: 40, height: 3)

            Text("TALLY")
                .font(.manrope(.medium, size: 11))
                .foregroundStyle(Color.mutedText)
        }
    }
}

#Preview("Forgot Password - Form") {
    ForgotPasswordView(onBackToLogin: {})
}
