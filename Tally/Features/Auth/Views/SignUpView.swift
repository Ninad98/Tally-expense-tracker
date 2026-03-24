//
//  SignUpView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/22/26.
//

import SwiftUI

struct SignUpView: View {

    @ObservedObject var viewModel: SignUpViewModel
    let onBackToLogin: () -> Void
    let onCreateAccount: () -> Void

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 24)

                    formSection
                        .padding(.top, 8)

                    createAccountButton
                        .padding(.top, 32)

                    AuthOrDivider()
                        .padding(.top, 32)

                    AuthSocialButtonsRow()
                        .padding(.top, 24)

                    footerLoginLink
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Decorative background

    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(Color.primaryBlue.opacity(0.12))
                .frame(width: 192, height: 192)
                .blur(radius: 48)
                .offset(x: -120, y: -180)

            Circle()
                .fill(Color.primaryBlue.opacity(0.08))
                .frame(width: 192, height: 192)
                .blur(radius: 48)
                .offset(x: 160, y: 380)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Join Us")
                .font(.urbanist(.extraBold, size: 36))
                .foregroundStyle(Color.heading)
                .tracking(-0.9)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text("Enter your details to get started.")
                .font(.manrope(.medium, size: 16))
                .foregroundStyle(Color.bodyText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 16) {
            labeledField(
                title: "Full Name",
                systemImage: "person",
                text: $viewModel.fullName,
                placeholder: "John Doe",
                error: viewModel.fullNameError,
                isSecure: false,
                useEmailKeyboard: false
            )
            .onChange(of: viewModel.fullName) { _, _ in
                if viewModel.fullNameError != nil { viewModel.validateFullName() }
            }

            labeledField(
                title: "Email Address",
                systemImage: "envelope",
                text: $viewModel.email,
                placeholder: "name@example.com",
                error: viewModel.emailError,
                isSecure: false,
                useEmailKeyboard: true
            )
            .onChange(of: viewModel.email) { _, _ in
                if viewModel.emailError != nil { viewModel.validateEmail() }
            }

            labeledField(
                title: "Password",
                systemImage: "lock",
                text: $viewModel.password,
                placeholder: "Enter password",
                error: viewModel.passwordError,
                isSecure: true,
                useEmailKeyboard: false
            )
            .onChange(of: viewModel.password) { _, _ in
                if viewModel.passwordError != nil { viewModel.validatePassword() }
            }
        }
        .padding(.horizontal, 8)
    }

    private func labeledField(
        title: String,
        systemImage: String,
        text: Binding<String>,
        placeholder: String,
        error: String?,
        isSecure: Bool,
        useEmailKeyboard: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.mutedText)
                    .frame(width: 20)

                innerTextField(
                    text: text,
                    placeholder: placeholder,
                    isSecure: isSecure,
                    useEmailKeyboard: useEmailKeyboard
                )
                .font(.manrope(.regular, size: 16))
                .foregroundStyle(Color.heading)

                if error != nil {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.errorRose)
                } else if isSecure {
                    Button {
                        viewModel.isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.mutedText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error != nil ? Color.errorRose : Color.cardBorder, lineWidth: error != nil ? 1.5 : 1)
            )

            if let error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(.manrope(.regular, size: 12))
                    .foregroundStyle(Color.errorRose)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            }
        }
    }

    @ViewBuilder
    private func innerTextField(
        text: Binding<String>,
        placeholder: String,
        isSecure: Bool,
        useEmailKeyboard: Bool
    ) -> some View {
        if isSecure {
            if viewModel.isPasswordVisible {
                TextField("", text: text, prompt: Text(placeholder).foregroundStyle(Color.mutedText))
            } else {
                SecureField(placeholder, text: text)
            }
        } else if useEmailKeyboard {
            TextField("", text: text, prompt: Text(placeholder).foregroundStyle(Color.mutedText))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        } else {
            TextField("", text: text, prompt: Text(placeholder).foregroundStyle(Color.mutedText))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        }
    }

    // MARK: - Primary button

    private var createAccountButton: some View {
        Button {
            viewModel.createAccount(onSuccess: onCreateAccount)
        } label: {
            Text("Create Account")
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
        .padding(.horizontal, 8)
    }

    // MARK: - Footer

    private var footerLoginLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.bodyText)
            Button("Login") {
                onBackToLogin()
            }
            .font(.manrope(.bold, size: 14))
            .foregroundStyle(Color.primaryBlue)
        }
    }
}

// MARK: - SignUpFlowView

struct SignUpFlowView: View {
    private enum Step {
        case form
        case done
    }

    @StateObject private var viewModel = SignUpViewModel()
    @State private var step: Step = .form

    let onBackToLogin: () -> Void

    var body: some View {
        Group {
            switch step {
            case .form:
                SignUpView(
                    viewModel: viewModel,
                    onBackToLogin: onBackToLogin,
                    onCreateAccount: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            step = .done
                        }
                    }
                )
            case .done:
                SignUpDoneView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        onBackToLogin()
                    }
                }
            }
        }
    }
}

#Preview("Sign up") {
    SignUpFlowView(onBackToLogin: {})
}

#Preview("Sign up (errors)") {
    SignUpErrorPreview()
}

private struct SignUpErrorPreview: View {
    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        SignUpView(viewModel: viewModel, onBackToLogin: {}, onCreateAccount: {})
            .onAppear {
                viewModel.fullName = "J"
                viewModel.email = "not-an-email"
                viewModel.password = "123"
                viewModel.validateAll()
            }
    }
}
