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

    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
    }

    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var avatarImage: UIImage?
    @Published var isLoading = false
    @Published var isSavingPhoto = false
    @Published var errorMessage: String?

    // Fetch fullName, email and profilePhoto as base64 from firestore.
    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        Task {
            let profile = await firebaseService.fetchUserProfile(uid: uid)
            await MainActor.run {
                if let profile {
                    fullName = profile.fullName
                    let firestoreEmail = profile.email
                    email = firestoreEmail.isEmpty ? (Auth.auth().currentUser?.email ?? "") : firestoreEmail
                    avatarImage = ProfilePhotoEncoding.uiImage(fromBase64: profile.profilePhoto)
                } else {
                    fullName = Auth.auth().currentUser?.displayName ?? ""
                    email = Auth.auth().currentUser?.email ?? ""
                    avatarImage = nil
                }
                isLoading = false
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
}
