//
//  ProfileView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/24/26.
//


import PhotosUI
import SwiftUI

struct ProfileView: View {

    var onLogout: () -> Void = {}

    // To keep track of the action for the settings rows.
    private enum SettingAction {
        case chevron
        case none
        case toggle(Binding<Bool>)
    }

    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var biometricManager: BiometricAuthManager
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showEditFullName = false
    @State private var fullNameDraft = ""

    // To keep track if notifications are enabled or not.
    @State private var notificationsEnabled = true
    @State private var logoutError: String?
    @State private var showLogoutDialog = false

    var body: some View {
        ZStack {
            Color.pageBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Profile")
                        .font(.urbanist(.bold, size: 18))
                        .foregroundStyle(Color.heading)
                    avatarSection
                    personalInfoSection
                    securitySection
                    financialSection
                    appSettingsSection
                    logOutButton
                    versionLabel
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
        .onAppear { viewModel.loadProfile() }
        .alert("Edit full name", isPresented: $showEditFullName) {
            TextField("Full name", text: $fullNameDraft)
                .textInputAutocapitalization(.words)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                Task { await viewModel.updateFullName(fullNameDraft) }
            }
            .disabled(viewModel.isUpdatingFullName)
        } message: {
            Text("This name is saved to your account.")
        }
        .onChange(of: showEditFullName) { _, isShowing in
            if isShowing {
                fullNameDraft = viewModel.fullName
            }
        }
        .onChange(of: viewModel.isUpdatingFullName) { _, saving in
            if !saving, viewModel.errorMessage == nil {
                showEditFullName = false
            }
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            if newValue != nil {
                showEditFullName = false
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Log out failed", isPresented: Binding(
            get: { logoutError != nil },
            set: { if !$0 { logoutError = nil } }
        )) {
            Button("OK", role: .cancel) { logoutError = nil }
        } message: {
            Text(logoutError ?? "")
        }
        .sheet(isPresented: $showLogoutDialog) {
            LogoutConfirmationSheet(onConfirm: performLogout)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.hidden)
                .presentationBackground(Color.pageBG)
        }
    }

    private func performLogout() {
        do {
            try Authentication().logout()
            biometricManager.isLocked = false
            onLogout()
        } catch {
            logoutError = error.localizedDescription
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Group {
                        if let image = viewModel.avatarImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Circle()
                                .fill(Color.primaryBlue.opacity(0.1))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.primaryBlue.opacity(0.6))
                                )
                        }
                    }
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())

                    if viewModel.isSavingPhoto {
                        Circle()
                            .fill(Color.black.opacity(0.25))
                            .frame(width: 96, height: 96)
                        ProgressView()
                            .tint(.white)
                    }
                }

                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    ZStack {
                        Circle()
                            .fill(Color.primaryBlue)
                            .frame(width: 28, height: 28)
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSavingPhoto)
                .offset(x: 2, y: 2)
            }

            Text(viewModel.fullName.isEmpty ? "—" : viewModel.fullName)
                .font(.urbanist(.bold, size: 20))
                .foregroundStyle(Color.heading)

            Text(viewModel.email.isEmpty ? "—" : viewModel.email)
                .font(.manrope(.regular, size: 14))
                .foregroundStyle(Color.mutedText)
        }
        .padding(.vertical, 8)
        .onChange(of: photoPickerItem) { _, newItem in
            guard newItem != nil else { return }
            Task {
                await viewModel.handlePickedPhotoItem(newItem)
                photoPickerItem = nil
            }
        }
    }

    private var personalInfoSection: some View {
        settingsGroup(title: "PERSONAL INFO") {
            VStack(spacing: 0) {
                Button {
                    fullNameDraft = viewModel.fullName
                    showEditFullName = true
                } label: {
                    settingsRow(
                        icon: "person.fill",
                        iconBG: Color.primaryBlue.opacity(0.1),
                        iconColor: Color.primaryBlue,
                        title: "Full Name",
                        subtitle: viewModel.fullName.isEmpty ? "—" : viewModel.fullName,
                        trailing: .chevron
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isUpdatingFullName)

                Divider()
                    .padding(.leading, 56)

                settingsRow(
                    icon: "envelope.fill",
                    iconBG: Color.primaryBlue.opacity(0.1),
                    iconColor: Color.primaryBlue,
                    title: "Email Address",
                    subtitle: viewModel.email.isEmpty ? "—" : viewModel.email,
                    trailing: .none,
                    readOnly: true
                )
            }
        }
    }

    private var securitySection: some View {
        settingsGroup(title: "SECURITY") {
            VStack(spacing: 0) {
                settingsRow(
                    icon: "lock.fill",
                    iconBG: Color.heading.opacity(0.08),
                    iconColor: Color.heading,
                    title: "Change Password",
                    subtitle: nil,
                    trailing: .chevron
                )

                Divider()
                    .padding(.leading, 56)

                settingsRow(
                    icon: "faceid",
                    iconBG: Color.primaryBlue.opacity(0.1),
                    iconColor: Color.primaryBlue,
                    title: "Biometric Login",
                    subtitle: biometricManager.isAvailable
                        ? "Use FaceID or Fingerprint"
                        : "Not available on this device",
                    trailing: biometricManager.isAvailable
                        ? .toggle($biometricManager.isEnabled)
                        : .none,
                    readOnly: !biometricManager.isAvailable
                )
            }
        }
    }

    private var financialSection: some View {
        settingsGroup(title: "FINANCIAL") {
            settingsRow(
                icon: "creditcard.fill",
                iconBG: Color.primaryBlue.opacity(0.1),
                iconColor: Color.primaryBlue,
                title: "Wallet Settings",
                subtitle: "Default: Main Wallet",
                trailing: .chevron
            )
        }
    }
    private var appSettingsSection: some View {
        settingsGroup(title: "APP SETTINGS") {
            settingsRow(
                icon: "bell.fill",
                iconBG: Color.primaryBlue.opacity(0.1),
                iconColor: Color.primaryBlue,
                title: "Push Notifications",
                subtitle: "Spending alerts & weekly reports",
                trailing: .toggle($notificationsEnabled)
            )
        }
    }

    private var logOutButton: some View {
        Button {
            showLogoutDialog = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .bold))
                Text("Log Out")
                    .font(.manrope(.bold, size: 16))
            }
            .foregroundStyle(Color.errorRose)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.errorRose.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // TODO: I would want to have the version pushed to firestore and fetch it from there.
    private var versionLabel: some View {
        Text("Version 2.4.0 · Build 1024")
            .font(.manrope(.regular, size: 12))
            .foregroundStyle(Color.mutedText)
    }


    // Reusable stylings for the settings groups.
    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.manrope(.bold, size: 12))
                .foregroundStyle(Color.mutedText)
                .tracking(1)

            content()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        }
    }

    // Reusable stylings for the settings rows.
    private func settingsRow(
        icon: String,
        iconBG: Color,
        iconColor: Color,
        title: String,
        subtitle: String?,
        trailing: SettingAction,
        readOnly: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBG)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manrope(.bold, size: 14))
                    .foregroundStyle(readOnly ? Color.mutedText : Color.heading)
                if let subtitle {
                    Text(subtitle)
                        .font(.manrope(.regular, size: 12))
                        .foregroundStyle(Color.mutedText)
                        .lineLimit(1)
                }
            }

            Spacer()

            switch trailing {
            case .chevron:
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.mutedText)
            case .none:
                EmptyView()
            case .toggle(let binding):
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .tint(Color.primaryBlue)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .opacity(readOnly ? 0.72 : 1)
    }
}

private struct LogoutConfirmationSheet: View {

    @Environment(\.dismiss) private var dismiss
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.errorRose.opacity(0.15))
                    .frame(width: 76, height: 76)
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.errorRose)
            }

            Text("Logout?")
                .font(.urbanist(.bold, size: 22))
                .foregroundStyle(Color.heading)

            Text("Are you sure you want to log out of your account?")
                .font(.manrope(.regular, size: 14))
                .foregroundStyle(Color.mutedText)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button {
                    onConfirm()
                    dismiss()
                } label: {
                    Text("Logout")
                        .font(.manrope(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.errorRose)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.manrope(.bold, size: 16))
                        .foregroundStyle(Color.errorRose)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.errorRose.opacity(0.12))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

#Preview {
    ProfileView()
        .environmentObject(BiometricAuthManager())
}
