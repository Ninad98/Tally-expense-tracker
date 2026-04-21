//
//  ChangePasswordSheet.swift
//  Tally
//
//  Created by Mazen Tarek on 4/17/26.
//

import SwiftUI

struct ChangePasswordSheet: View {

    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var isCurrentVisible = false
    @State private var isNewVisible = false
    @State private var isConfirmVisible = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Enter your current password and new password.")
                        .font(.manrope(.medium, size: 15))
                        .foregroundStyle(Color.bodyText)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)

                    VStack(spacing: 16) {
                        secureLabeledField(
                            title: "Current Password",
                            text: $currentPassword,
                            placeholder: "Enter current password",
                            isVisible: $isCurrentVisible
                        )

                        secureLabeledField(
                            title: "New Password",
                            text: $newPassword,
                            placeholder: "At least 8 characters",
                            isVisible: $isNewVisible
                        )

                        secureLabeledField(
                            title: "Confirm New Password",
                            text: $confirmPassword,
                            placeholder: "Re-enter new password",
                            isVisible: $isConfirmVisible
                        )
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 8)

                    if let err = viewModel.changePasswordError {
                        Label(err, systemImage: "exclamationmark.circle")
                            .font(.manrope(.regular, size: 14))
                            .foregroundStyle(Color.errorRose)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.top, 16)
                    }

                    updateButton
                        .padding(.top, 28)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color.pageBG)
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.manrope(.medium, size: 16))
                    .foregroundStyle(Color.primaryBlue)
                }
            }
        }
        .onDisappear {
            viewModel.changePasswordError = nil
        }
    }

    private var updateButton: some View {
        Button {
            Task {
                let ok = await viewModel.changePassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword,
                    confirmation: confirmPassword
                )
                if ok {
                    dismiss()
                }
            }
        } label: {
            ZStack {
                if viewModel.isChangingPassword {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Update Password")
                        .font(.urbanist(.bold, size: 18))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .disabled(viewModel.isChangingPassword)
    }

    // Repurposed from login and signup
    private func secureLabeledField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        isVisible: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.manrope(.medium, size: 14))
                .foregroundStyle(Color.heading)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.mutedText)
                    .frame(width: 20)

                Group {
                    if isVisible.wrappedValue {
                        TextField("", text: text, prompt: Text(placeholder).foregroundStyle(Color.mutedText))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }
                .font(.manrope(.regular, size: 16))
                .foregroundStyle(Color.heading)

                Button {
                    isVisible.wrappedValue = !isVisible.wrappedValue
                } label: {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.mutedText)
                }
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
}

#Preview {
    ChangePasswordSheet(viewModel: ProfileViewModel())
}
