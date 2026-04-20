//
//  ProfileViewModel.swift
//  Tally
//
//  Created by Mazen Tarek on 4/12/26.
//

import Combine
import FirebaseAuth
import PhotosUI
import SwiftUI
import UIKit

final class ProfileViewModel: ObservableObject {

    private static let linkedDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var avatarImage: UIImage?
    @Published var isLoading = false
    @Published var isSavingPhoto = false
    @Published var isUpdatingFullName = false
    @Published var errorMessage: String?

    @Published var isEmailProvider = false
    @Published var passwordChangeUnavailable: String?
    @Published var isChangingPassword = false
    @Published var changePasswordError: String?

    // Plaid stuff.
    @Published var plaidItemID: String?
    @Published var plaidInstitutionName: String?
    @Published var plaidLinkedAt: Date?

    // Checks if bank is connected by checking the plaidItemId is set or not.
    var isBankConnected: Bool {
        guard let plaidItemID else {
            return false 
        }
        return !plaidItemID.isEmpty
    }

    // Checks if bank is connected by checking isBankConnected variable if it is set, then we show connected subtitle.
    var bankStatusSubtitle: String {
        guard isBankConnected else {
            return "Plaid" 
        }
        let institutionName = plaidInstitutionName ?? "Plaid"
        if let linkedAt = plaidLinkedAt {
            return "\(institutionName) - Connected - \(Self.linkedDateFormatter.string(from: linkedAt))"
        }
        return "\(institutionName) - Connected"
    }

    func refreshAuthProviders() {
        guard let user = Auth.auth().currentUser else {
            isEmailProvider = false
            passwordChangeUnavailable = nil
            return
        }
        let hasEmailPassword = user.providerData.contains { $0.providerID == EmailAuthProviderID }
        isEmailProvider = hasEmailPassword
        guard !hasEmailPassword else {
            passwordChangeUnavailable = nil
            return
        }
        if user.providerData.contains(where: { $0.providerID == GoogleAuthProviderID }) {
            passwordChangeUnavailable = "Managed by Google"
        } else {
            passwordChangeUnavailable = "Not available for this sign-in method"
        }
    }

    // Fetch fullName, email and profilePhoto as base64 from firestore.
    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        refreshAuthProviders()
        isLoading = true
        Task {
            let profile = await firebaseService.fetchUserProfile(uid: uid)
            await MainActor.run {
                if let profile {
                    fullName = profile.fullName
                    let firestoreEmail = profile.email
                    email = firestoreEmail.isEmpty ? (Auth.auth().currentUser?.email ?? "") : firestoreEmail
                    avatarImage = ProfilePhotoEncoding.uiImage(fromBase64: profile.profilePhoto)
                    plaidItemID = profile.plaidItemID
                    plaidInstitutionName = profile.plaidInstitutionName
                    plaidLinkedAt = profile.plaidLinkedAt
                } else {
                    fullName = Auth.auth().currentUser?.displayName ?? ""
                    email = Auth.auth().currentUser?.email ?? ""
                    avatarImage = nil
                    plaidItemID = nil
                    plaidInstitutionName = nil
                    plaidLinkedAt = nil
                }
                isLoading = false
                refreshAuthProviders()
            }
        }
    }

    // Takes in current password, new password and re-entered new password.
    func changePassword(currentPassword: String, newPassword: String, confirmation: String) async -> Bool {
        let trimmedNew = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmation.trimmingCharacters(in: .whitespacesAndNewlines)

        // Clears error messages and sets isChangingPassword to true.
        await MainActor.run {
            changePasswordError = nil
            isChangingPassword = true
        }

        // Checks if the account is an email provider and not Google signin.
        guard isEmailProvider else {
            await MainActor.run {
                changePasswordError = "Password change isn’t available for this account."
                isChangingPassword = false
            }
            return false
        }

        guard !currentPassword.isEmpty else {
            await MainActor.run {
                changePasswordError = "Enter your current password."
                isChangingPassword = false
            }
            return false
        }

        guard trimmedNew.count >= 8 else {
            await MainActor.run {
                changePasswordError = "New password must be at least 8 characters."
                isChangingPassword = false
            }
            return false
        }

        guard trimmedNew == trimmedConfirm else {
            await MainActor.run {
                changePasswordError = "New passwords don’t match."
                isChangingPassword = false
            }
            return false
        }

        guard trimmedNew != currentPassword else {
            await MainActor.run {
                changePasswordError = "New password must be different from your current password."
                isChangingPassword = false
            }
            return false
        }

        guard let user = Auth.auth().currentUser,
              let emailAddress = user.email, !emailAddress.isEmpty else {
            await MainActor.run {
                changePasswordError = "Could not read your account email."
                isChangingPassword = false
            }
            return false
        }

        // Authenticates with current password to verify, then updates to new password.
        do {
            let credential = EmailAuthProvider.credential(withEmail: emailAddress, password: currentPassword)
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: trimmedNew)
            await MainActor.run { isChangingPassword = false }
            return true
        } catch {
            let mapped = FirebaseAuthErrorMapping.mapChangePassword(error)
            let message: String
            switch mapped {
            case .currentPassword(let msg), .newPassword(let msg), .general(let msg):
                message = msg
            }
            await MainActor.run {
                changePasswordError = message
                isChangingPassword = false
            }
            return false
        }
    }

    func updateFullName(_ name: String) async {

        // Validate that the name is not empty or just whitespaces.
        let inputName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !inputName.isEmpty else {
            await MainActor.run { errorMessage = "Name can't be empty." }
            return
        }

        await MainActor.run {
            isUpdatingFullName = true
            errorMessage = nil
        }

        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                await MainActor.run {
                    errorMessage = "Not signed in."
                    isUpdatingFullName = false
                }
                return
            }
            try await firebaseService.updateUserFullName(uid: uid, fullName: inputName)
            await MainActor.run {
                fullName = inputName
                isUpdatingFullName = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isUpdatingFullName = false
            }
        }
    }

    // Attribution: https://developer.apple.com/documentation/photosui/photospicker
    // Attribution: https://developer.apple.com/documentation/photosui/photospickeritem
    func handlePickedPhotoItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        await MainActor.run {
            isSavingPhoto = true
            errorMessage = nil
        }

        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                await MainActor.run { errorMessage = "Not signed in."; isSavingPhoto = false }
                return
            }
            guard let data = try await item.loadTransferable(type: Data.self) else {
                await MainActor.run { errorMessage = "Could not read the photo."; isSavingPhoto = false }
                return
            }
            guard let base64 = ProfilePhotoEncoding.jpegBase64(fromImageData: data) else {
                await MainActor.run { errorMessage = "Could not compress the photo. Try a smaller image."; isSavingPhoto = false }
                return
            }
            try await firebaseService.updateUserImage(uid: uid, jpegBase64: base64)
            await MainActor.run {
                avatarImage = ProfilePhotoEncoding.uiImage(fromBase64: base64)
                isSavingPhoto = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isSavingPhoto = false
            }
        }
    }

    func saveLinkedBank(itemID: String, institutionName: String?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "ProfileViewModel",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Error saving bank."]
            )
        }
        try await firebaseService.savePlaidLink(
            uid: uid,
            itemID: itemID,
            institutionName: institutionName
        )

        await MainActor.run {
            plaidItemID = itemID
            plaidInstitutionName = institutionName
            plaidLinkedAt = Date()
        }
    }
}
