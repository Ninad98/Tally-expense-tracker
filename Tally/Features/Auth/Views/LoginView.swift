//
//  LoginView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/20/26.
//

import SwiftUI

struct LoginView: View {

    let onLoginSuccess: () -> Void
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 72, height: 72)
                        Image(systemName: "lock.square.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }

                    Text("Welcome Back")
                        .font(.title.bold())

                    Text("Enter your details to access your account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 48)

                // MARK: - Form
                VStack(spacing: 16) {

                    // Email Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.secondary)
                            TextField("name@example.com", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .onChange(of: viewModel.email) { _ in
                                    if viewModel.emailError != nil { viewModel.validateEmail() }
                                }
                            if viewModel.emailError != nil {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.emailError != nil ? Color.red : Color(.systemGray4), lineWidth: 1.5)
                        )
                        .cornerRadius(12)

                        if let error = viewModel.emailError {
                            Label(error, systemImage: "exclamationmark.circle")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.secondary)
                            if viewModel.isPasswordVisible {
                                TextField("...............", text: $viewModel.password)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("...............", text: $viewModel.password)
                            }
                            Button {
                                viewModel.isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.passwordError != nil ? Color.red : Color(.systemGray4), lineWidth: 1.5)
                        )
                        .cornerRadius(12)
                        .onChange(of: viewModel.password) { _ in
                            if viewModel.passwordError != nil { viewModel.validatePassword() }
                        }

                        if let error = viewModel.passwordError {
                            Label(error, systemImage: "exclamationmark.circle")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            // TODO: Navigate to forgot password
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

                // MARK: - Login Button
                Button {
                    viewModel.login(onSuccess: onLoginSuccess)
                } label: {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.blue)
                    .cornerRadius(14)
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                // MARK: - Social Login
                VStack(spacing: 16) {
                    HStack {
                        line
                        Text("OR CONTINUE WITH")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        line
                    }
                    .padding(.horizontal)

                    HStack(spacing: 16) {
                        // Google Button
                        Button {
                            // TODO: Google sign-in
                        } label: {
                            HStack(spacing: 8) {
                                GoogleIcon()
                                Text("Google")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                        }

                        // Apple Button
                        Button {
                            // TODO: Apple sign-in
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Apple")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: - Sign Up
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign Up") {
                        // TODO: Navigate to sign up
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var line: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color(.systemGray4))
    }
}

// MARK: - Google Icon
private struct GoogleIcon: View {
    var body: some View {
        ZStack {
            Text("G")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .red, .yellow, .green],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(width: 20, height: 20)
    }
}

#Preview {
    LoginView(onLoginSuccess: {})
}
