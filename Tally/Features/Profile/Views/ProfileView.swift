//
//  ProfileView.swift
//  Tally
//
//  Created by Ninad Mankar on 3/24/26.
//


import SwiftUI

struct ProfileView: View {

    // To keep track of the action for the settings rows.
    private enum SettingAction {
        case chevron
        case toggle(Binding<Bool>)
    }

    // To keep track if biometric is enabled for login or not.
    @State private var biometricEnabled = true
    // To keep track if notifications are enabled or not.
    @State private var notificationsEnabled = true

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
    }

    private var avatarSection: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.primaryBlue.opacity(0.6))
                    )

                Button {
                    // TODO: I should make the profile picture editable and persist in firestore.
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.primaryBlue)
                            .frame(width: 28, height: 28)
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .offset(x: 2, y: 2)
            }

            // TODO: Fetch full name and email from firestore.
            Text("Mazen Hussein")
                .font(.urbanist(.bold, size: 20))
                .foregroundStyle(Color.heading)

            Text("mazen.huss@example.com")
                .font(.manrope(.regular, size: 14))
                .foregroundStyle(Color.mutedText)
        }
        .padding(.vertical, 8)
    }

    // TODO: Make full name editable but not email.
    private var personalInfoSection: some View {
        settingsGroup(title: "PERSONAL INFO") {
            VStack(spacing: 0) {
                settingsRow(
                    icon: "person.fill",
                    iconBG: Color.primaryBlue.opacity(0.1),
                    iconColor: Color.primaryBlue,
                    title: "Full Name",
                    subtitle: "Mazen Hussein",
                    trailing: .chevron
                )

                Divider()
                    .padding(.leading, 56)

                settingsRow(
                    icon: "envelope.fill",
                    iconBG: Color.primaryBlue.opacity(0.1),
                    iconColor: Color.primaryBlue,
                    title: "Email Address",
                    subtitle: "mazen.huss@example.com",
                    trailing: .chevron
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

                // TODO: Implement biometric login.
                settingsRow(
                    icon: "faceid",
                    iconBG: Color.primaryBlue.opacity(0.1),
                    iconColor: Color.primaryBlue,
                    title: "Biometric Login",
                    subtitle: "Use FaceID or Fingerprint",
                    trailing: .toggle($biometricEnabled)
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
            // TODO: Logout user and navigate back to login screen.
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
        trailing: SettingAction
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
                    .foregroundStyle(Color.heading)
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
            case .toggle(let binding):
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .tint(Color.primaryBlue)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
}
