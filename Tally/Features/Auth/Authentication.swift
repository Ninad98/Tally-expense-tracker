//
//  Authentication.swift
//  Tally
//
// Created by Mazen Tarek on 3/29/26.
//

// Attribution: https://medium.com/@matteocuzzolin/google-sign-in-with-firebase-in-swiftui-app-c8dc7b7ed4f9
// By Matteo Cuzzolin

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

struct Authentication {

    @MainActor
    func googleOauth() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No Firebase clientID found")
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController else {
            fatalError("There is no root view controller!")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthenticationError.runtimeError("Unexpected error occurred, please retry")
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        let googleUser = try await Auth.auth().signIn(with: credential)

        // Saving user from google to firestore
        try await saveGoogleToFirestore(user: googleUser.user)
    }

    private func saveGoogleUserToFirestore(user: User) async throws {

        let currencyId = UserDefaults.standard.string(forKey: "selectedCurrency")

        try await FirebaseService().saveUserToFirestore(
            uid: user.uid,
            email: user.email ?? "",
            fullName: user.displayName ?? "",
            selectedCurrencyId: currencyId
        )
    }

    func logout() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}

enum AuthenticationError: Error {
    case runtimeError(String)
}
