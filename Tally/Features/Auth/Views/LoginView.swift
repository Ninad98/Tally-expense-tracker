//
//  LoginView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/20/26.
//

import SwiftUI

struct LoginView: View {

    let onLoginSuccess: () -> Void
    let onSignUp: () -> Void
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {


                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.primaryBlue.opacity(0.1))
                            .frame(width: 72, height: 72)
                        Image("Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                    }

                    Text("Welcome Back")
                        .font(.title.bold())

                    Text("Enter your details to access your account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 48)


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
                                .onChange(of: viewModel.email) { _, _ in
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
                        .onChange(of: viewModel.password) { _, _ in
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


                AuthSocialLoginBlock()
                    .padding(.horizontal)


                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign Up") {
                        onSignUp()
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
}

#Preview {
    LoginView(onLoginSuccess: {}, onSignUp: {})
}
